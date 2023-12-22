class DevelopersDailyReconciliationJob
  include Shoryuken::Worker

  shoryuken_options queue: ENV['SQS_DEVELOPERS_DAILY_RECONCILIATION_QUEUE_NAME'], auto_delete: true, retry_intervals: [ENV['RECONCILIATION_FIRST_RETRY_INTERVAL'].to_i, ENV['RECONCILIATION_SECOND_RETRY_INTERVAL'].to_i]

  # NB: daily once at 01:00 am (Singapore timezone)
  # Retry interval: 15 mins & 30 mins respectively
  def perform(sqs_msg, msg_body)
    return
    Rails.logger.info 'Starting Developers Daily Reconciliation Job ============'
    data = DeveloperDataParser.new.parse
    developers_data = data || []

    developers_data.each do |developer|
      Developer.create_developer(developer)
    end

    Rails.logger.info "End of Developers Daily Reconciliation Job ============"
  rescue => e
    Sentry.capture_message("DevelopersDailyReconciliationJob: #{e.message}")
    receive_count = sqs_msg.attributes['ApproximateReceiveCount'].to_i

    if receive_count < 3
      raise
    else
      Rails.logger.info "============ Finished 2nd Retry ============"
    end
  end
end
