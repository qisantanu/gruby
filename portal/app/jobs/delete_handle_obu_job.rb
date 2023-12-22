# frozen_string_literal: true

# This job will be executed every night
class DeleteHandleObuJob < ApplicationJob
  queue_as ENV['SQS_DELETE_HANDLE_OBU_JOBS_QUEUE_NAME']

  # This job will delete the completed handle_obu_jobs which created before 7 days
  def perform
    Rails.logger.info 'Starting of DeleteHandleObuJob ============'
    handle_obu_jobs = HandleObuJob.where(status: [HandleObuJob::STATUS[:completed], HandleObuJob::STATUS[:rejected]]).where('created_at < ?', 7.days.ago)

    if handle_obu_jobs.blank?
      Rails.logger.info('no records to HandleObuJob process')
    else
      handle_obu_jobs.delete_all
    end

    Rails.logger.info 'End of DeleteHandleObuJob ============'
  rescue StandardError => e
    Sentry.capture_message("DeleteHandleObuJob: #{e.message}")
  end
end
