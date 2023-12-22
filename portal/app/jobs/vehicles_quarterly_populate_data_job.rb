# frozen_string_literal: true

class VehiclesQuarterlyPopulateDataJob < ApplicationJob
  queue_as ENV['SQS_VEHICLES_QUARTERLY_POPULATE_DATA_QUEUE_NAME']

  RETRY_COUNT = 3
  # This job executed 4 times a year
  # NCS will upload at 1:30 AM SGT on April 3, July 3, October 3 and January 3.
  # Quarterly job should be executed daily at 2:30 AM SGT.
  # This job will create AwsObuFile for each of the file uploaded by NCS in our s3 on the current date
  def perform(*_args)
    Rails.logger.info 'Starting Vehicles Quarterly Populate Data Job ============'
    retries ||= 0
    uploaded_objects = fetch_s3_file_for_today
    uploaded_objects.each do |obj|
      AwsObuFile.create(file_name: obj.key, is_daily: false, file_last_updated_on: obj.last_modified, started_at: Time.zone.now)
    end
    Rails.logger.info 'End of Vehicles Quarterly Populate Data Job ============'
  rescue StandardError => e
    Sentry.capture_message("VehiclesQuarterlyPopulateDataJob: #{e.message}")
    retry if (retries += 1) < RETRY_COUNT
  end

  # This method will return all the object uploaded on current date
  def fetch_s3_file_for_today
    return ENV['TEST_OBU_PUBLIC_KEY_FILE_NAME'] if ENV['TEST_OBU_PUBLIC_KEY_FILE_NAME'].present?

    current_date = Time.zone.now.to_date
    period_info = 'Q'
    file_name_prefix = "ERP2-SDK-PBLIC-KEY-#{period_info}2-#{current_date.strftime('%Y')}"
    Rails.logger.info "Searching file in s3 with prefix #{file_name_prefix} ------>"
    # List all objects with the prefix
    resp = S3ManagementPortal.s3.list_objects({ bucket: ENV['S3_BUCKET_OBU_PUBLIC_KEYS'], prefix: file_name_prefix }).contents

    # Filter objects that were uploaded today
    uploaded_today_objects = resp.select do |object|
      object.last_modified.in_time_zone("Asia/Singapore").to_date == current_date
    end
    uploaded_today_objects
  end
end
