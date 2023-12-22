class SendEmailsToDevelopersJob < ApplicationJob
  queue_as ENV['SQS_SEND_EMAILS_TO_DEVELOPERS_QUEUE_NAME']

  def perform(email_id)
    Rails.logger.info "Start sending emails ============"

    email = Email.find(email_id)
    recipient_developers = Rails.env.production? ? email.developers : email.developers.where("lower(email) in (?)", ENV['WHITELISTED_DEVELOPER_EMAILS'].presence.to_s.split(',').map(&:downcase))

    recipient_developers.find_each do |developer|
      Rails.logger.info "Sending email to #{developer.email} ------------->"
      DeveloperMailer.send_notification_email(email, developer).deliver_now
    end

    Rails.logger.info "Finished sending emails ============"
  end
end
