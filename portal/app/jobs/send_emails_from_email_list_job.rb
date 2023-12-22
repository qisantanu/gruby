# frozen_string_literal: true
# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

# This job supposed to be run at 2pm to 12AM everyday
# 50 emails between 2-3pm
# No email between 3-4pm
# 500 emails between 4pm-12am
# No email between 12am-2pm
class SendEmailsFromEmailListJob < ApplicationJob
  queue_as ENV['SQS_SEND_EMAILS_FROM_EMAIL_LIST_QUEUE_NAME']

  def perform
    Rails.logger.info('Start sending emails from Email List ============')
    current_sgt_time = Time.zone.now
    current_date = current_sgt_time.to_date
    batch_count_per_min = ENV.fetch('EMAIL_JOB_BATCH', 9).to_i
    # here we are checking if the time is within 12AM to 2PM, then no email will be sent
    # If we need to change the timeframe, change logic here
    # Since we have decided to remove the restriction, we are commenting out the below code block
    # if current_sgt_time > current_date + 0.hour && current_sgt_time < current_date + 14.hours
    #   Rails.logger.info('Current time is outside of the time scope')
    #   return
    # end

    if EmailList.initiated.count.zero?
      Rails.logger.info('No more EmailList to be sent')
      return
    end

    Rails.logger.info("========= #{current_sgt_time}")
    # 50 emails between 2-3pm
    # No email between 3-4pm
    # 500 emails between 4pm-12am
    # No email between 12am-2pm
    if current_sgt_time > current_date + 14.hours && current_sgt_time < current_date + 15.hours
      # 50 emails per hour
      threashold = 50
      email_sent = EmailList.where.not(sent_at: nil)
                            .where(sent_at: (current_date + 14.hours)..(current_date + 15.hours))
                            .count
      return if email_sent >= threashold
    elsif current_sgt_time > current_date + 15.hours && current_sgt_time < current_date + 16.hours
      # 0 emails per hour
      Rails.logger.info('No email needs to be sent in this time')
      return
    else
      # 500 emails per hour
      threashold = 500
      # determine the current hour, so that we can get start and end time of the hour
      current_hour = current_sgt_time.strftime('%H').to_i
      start_time = current_date + current_hour.hours
      end_time = current_date + (current_hour + 1).hours

      email_sent = EmailList.where.not(sent_at: nil)
                            .where(sent_at: start_time..end_time)
                            .count
      return if email_sent >= threashold
    end

    Rails.logger.info("Email sent in this period of one hour: #{email_sent}")
    remaining_emails_to_be_sent = threashold - email_sent
    batch_count_per_min = remaining_emails_to_be_sent if remaining_emails_to_be_sent < batch_count_per_min
    Rails.logger.info("Batch count per minute: #{batch_count_per_min}")

    # Test the threshold

    email_list_ids = EmailList.initiated.first(batch_count_per_min).pluck(:id)
    email_lists = EmailList.where(id: email_list_ids)
    email_lists.update_all(status: EmailList::STATUS[:in_progress])

    email_lists.each do |el|
      dev = Developer.find_by_email(el.email.downcase)

      if dev
        if dev.active?
          begin
            if el.email_type == EmailList::TYPE[:developer_migration]
              DeveloperMailer.send_welcome_email(dev).deliver_now
              el.update(status: EmailList::STATUS[:completed], sent_at: Time.zone.now)
            end
          rescue StandardError => e
            Rails.logger.info "Error #{e.message}------>"
            el.update(status: EmailList::STATUS[:rejected], not_sending_reason: e.message)
            next
          end
        else
          Rails.logger.info "Developer is not active##{el.email} ============"
          el.update(status: EmailList::STATUS[:rejected], not_sending_reason: 'not active')
        end
      else
        Rails.logger.info "Developer not found SendEmailsFromEmailListJob##{el.email} ============"
      end
    end

    Rails.logger.info('Finished sending emails of SendEmailsFromEmailListJob ============')
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity