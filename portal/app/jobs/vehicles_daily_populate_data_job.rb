# frozen_string_literal: true

# This job will be executed in every 30 mins
# This job will create AwsObuFile for each of the file.
class VehiclesDailyPopulateDataJob < ApplicationJob
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  queue_as ENV['SQS_VEHICLES_DAILY_POPULATE_DATA_QUEUE_NAME']

  # This will set the value of how many times job will be retried if there is error
  RETRY_COUNT = 3

  # this is called and sent whatever parameters were sent when the job was first enqueued
  def perform(*_args)
    Rails.logger.info 'Starting Vehicle Daily Populate Data Job ============'
    retries ||= 0

    # preparing the file name
    current_sgt_time = Time.zone.now # this is application time as well
    # if it run at 12AM, 1AM it will consider the files for today and yesterday otherwise
    # it will consider the files which modified today
    uploaded_objects = if current_sgt_time.strftime('%p') == 'PM'
                         fetch_s3_file_for_specific_date(current_sgt_time.to_date)
                       elsif current_sgt_time.strftime('%p') == 'AM' && current_sgt_time < Time.zone.parse('2AM')
                         fetch_s3_file_for_specific_date(current_sgt_time.to_date) + fetch_s3_file_for_specific_date(current_sgt_time.yesterday.to_date)
                       else
                         fetch_s3_file_for_specific_date(current_sgt_time.to_date)
                       end

    sorted_uploaded_objects = uploaded_objects.sort_by(&:last_modified)

    sorted_uploaded_objects.uniq.each do |obj|
      AwsObuFile.create(file_name: obj.key, is_daily: true, file_last_updated_on: obj.last_modified,
                        started_at: Time.zone.now)
    end

    Rails.logger.info 'End of Vehicle Daily Populate Data Job ============'
  rescue StandardError => e
    Sentry.capture_message("VehiclesDailyPopulateDataJob: #{e.message}")
    retry if (retries += 1) < RETRY_COUNT
  end

  # This method will return all the objects uploaded on specific date
  # @param [Date] date to fetch s3 files
  #
  # @return [Array] array of Aws::Xml::DefaultList object
  def fetch_s3_file_for_specific_date(date)
    return ENV['TEST_OBU_PUBLIC_KEY_FILE_NAME'] if ENV['TEST_OBU_PUBLIC_KEY_FILE_NAME'].present?

    object_to_return = []
    period_info = 'D'
    file_name_prefix = "ERP2-SDK-PBLIC-KEY-#{period_info}2-#{date.strftime('%Y%m%d')}"
    Rails.logger.info "Searching file in s3 with prefix #{file_name_prefix} ------>"
    # List all objects with the prefix
    resp = S3ManagementPortal.s3.list_objects_v2({ bucket: ENV['S3_BUCKET_OBU_PUBLIC_KEYS'],
                                                   prefix: file_name_prefix })

    while resp.is_truncated
      # Filter objects that were uploaded on specific date
      object_to_return << resp.contents.select do |object|
        object.last_modified.in_time_zone("Asia/Singapore").to_date == date
      end

      continuation_token = resp.next_continuation_token

      resp = S3ManagementPortal.s3.list_objects_v2({ bucket: ENV['S3_BUCKET_OBU_PUBLIC_KEYS'],
                                                     prefix: file_name_prefix, continuation_token: continuation_token })
    end

    # Filter objects that were uploaded on specific date
    object_to_return << resp.contents.select do |object|
      object.last_modified.in_time_zone("Asia/Singapore").to_date == date
    end

    object_to_return.flatten
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
