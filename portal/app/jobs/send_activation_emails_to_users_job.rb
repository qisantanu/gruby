class SendActivationEmailsToUsersJob < ApplicationJob
  queue_as ENV['SQS_SEND_ACTIVATION_EMAIL_QUEUE_NAME']

  def perform(user_id, inviter_name)
    Rails.logger.info "Start sending email of SendActivationEmailsToUsersJob#{user_id}============"

    user = User.find_by(id: user_id)

    if user
      UserMailer.send_activation_email(user, inviter_name).deliver_now
    else
      Rails.logger.info "User not found SendActivationEmailsToUsersJob##{user_id}============"
    end

    Rails.logger.info "Finished SendActivationEmailsToUsersJob##{user_id}============"
  end
end
