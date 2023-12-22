# frozen_string_literal: true

# This job will process each file
# This job will be enqueued every minute
class ProcessObuFileJob < ApplicationJob
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  queue_as ENV['SQS_PROCESS_OBU_FILE_JOB_QUEUE_NAME']

  # This will set the value of how many times job will be retried if there is error
  RETRY_COUNT = 3

  # this is called and sent whatever parameters were sent when the job was first enqueued
  def perform
    Rails.logger.info 'Starting ProcessObuFileJob============'
    retries ||= 0
    obu_files = AwsObuFile.initiated

    AwsObuFile.in_progress.each do |obu_file|
      if obu_file.handle_obu_jobs_rejected?
        obu_file.update(status: AwsObuFile::STATUS[:rejected])
      elsif obu_file.handle_obu_jobs_completed?
        obu_file.update(status: AwsObuFile::STATUS[:completed])
      end
    end

    obu_files.each do |obu_file|
      obu_file.update(status: AwsObuFile::STATUS[:in_progress])
      Rails.logger.info("ProcessObuFileJob: start processign for #{obu_file.file_name}")
      VehicleDataParser.new(obu_file).parse
    end
    Rails.logger.info 'End of ProcessObuFileJob Data Job============'
  rescue StandardError => e
    Sentry.capture_message("ProcessObuFileJob: #{e.message}")
    retry if (retries += 1) < RETRY_COUNT
  end

  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
