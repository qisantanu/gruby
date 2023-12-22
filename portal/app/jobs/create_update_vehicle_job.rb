# frozen_string_literal: true

# This job will be run in every one minute
class CreateUpdateVehicleJob < ApplicationJob
  queue_as ENV['SQS_CREATE_UPDATE_VEHICLE_QUEUE_NAME']
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength

  # This method used to create or update the obu_details
  # This will take handle_obu_jobs which are in ready state according to the batch size (HANDLE_OBU_JOB_BATCH)
  # This will take the json_data from handle_obu_job and will create record in obu_details table if the vehicle's plate numbers are new otherwise it will update the record
  # This will also update handle_obu_jobs to ready state if it is in in_progress state from more than 30 minutes
  # @note HANDLE_OBU_JOB_BATCH is env variable
  def perform
    Rails.logger.info('Starting of CreateUpdateVehicleJob ============')
    handle_obu_jobs = HandleObuJob.ready.with_json_data.first(ENV.fetch('HANDLE_OBU_JOB_BATCH', 20).to_i)
    time_threshold = 30.minutes.ago

    # This is for processing the stale records which are there for a above time_threashold
    pending_in_progress_jobs = HandleObuJob.in_progress.with_json_data.where('updated_at < ?', time_threshold)
    pending_initiated_jobs = HandleObuJob.initiated.with_json_data.where('updated_at < ?', time_threshold)
    pending_in_progress_jobs.make_it_ready
    pending_initiated_jobs.make_it_ready

    if handle_obu_jobs.blank?
      Rails.logger.info('no records to HandleObuJob process')
      return
    end

    handle_obu_jobs.each do |hoj|
      hoj.update_columns(status: HandleObuJob::STATUS[:in_progress], updated_at: Time.zone.now)
    end

    handle_obu_jobs.each do |hoj|
      json_data = hoj.json_data
      # here json_data is an array
      next if json_data.blank?

      aws_obu_file_name = hoj.aws_obu_file.try(:file_name)
      Rails.logger.info("Processing HandleObuJob for the file named: #{aws_obu_file_name}")

      if hoj.retry_count > 2
        hoj.update(status: HandleObuJob::STATUS[:rejected])
        Sentry.capture_message("CreateUpdateVehicleJob: retried #{hoj.retry_count} times but failed")
      else
        hoj.update(retry_count: hoj.retry_count + 1)
        Rails.logger.info("CreateUpdateVehicleJob: retry_count set to #{hoj.retry_count} for HandleObuJob id: #{hoj.id}")
      end

      vehicle_hash_array = []
      json_data.each do |jd|
        vehicle_hash_array << VehicleDataParser.new(hoj.aws_obu_file).prepare_vehicle_hash(jd)
      end
      vehicle_hash_array = vehicle_hash_array.compact
      vehicle_number_arr = vehicle_hash_array.map{ |vh| vh[:vehicle_number] }
      exisiting_plate_numbers = ObuDetail.where(vehicle_registration_number: vehicle_number_arr).pluck(:vehicle_registration_number)

      new_plate_numbers = vehicle_number_arr - exisiting_plate_numbers
      vehicle_hash_array_with_new_plate_numbers = vehicle_hash_array.select { |i|
        new_plate_numbers.include?(i[:vehicle_number])
      }

      remaining_vehicle_hash_array = vehicle_hash_array.reject { |i|
        new_plate_numbers.include?(i[:vehicle_number])
      }

      if vehicle_hash_array_with_new_plate_numbers.present?
        ObuDetailForm.bulk_insert(vehicle_hash_array_with_new_plate_numbers)
      else
        Rails.logger.info('=======================================================')
      end

      remaining_vehicle_hash_array.each do |vehicle_hash|
        Rails.logger.info("creating vehicle for: #{vehicle_hash}")

        if vehicle_hash.present?
          Rails.logger.info 'Checking & creating vehicle data in db for vehicle ------>'
          obu_detail_form = ObuDetailForm.new(vehicle_hash)
          next if obu_detail_form.process

          # Redmine:100728 OBU replacement integration, detail is in the form
          obu_detail_form.replace
        else
          Rails.logger.info 'Vehicle data is empty.'
        end
      end

      hoj.update_columns(status: HandleObuJob::STATUS[:completed], updated_at: Time.zone.now)
      Rails.logger.info("One HandleObuJob record processing completed for the file named: #{aws_obu_file_name}")
    end

    Rails.logger.info 'End of CreateUpdateVehicleJob ============'
  rescue StandardError => e
    Sentry.capture_message("CreateUpdateVehicleJob: #{e.message}")
  ensure
    # if there are any error happened in any of the row, we need to
    # make sure the other rows are not delayed by 30 mins
    handle_obu_job_ids = handle_obu_jobs.pluck(:id)
    HandleObuJob.in_progress.where(id: handle_obu_job_ids).update_all(status: HandleObuJob::STATUS[:ready])

    if HandleObuJob.ready.exists?
      CreateUpdateVehicleJob.perform_later
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength
end
