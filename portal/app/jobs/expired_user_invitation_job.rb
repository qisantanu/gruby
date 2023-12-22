class ExpiredUserInvitationJob < ApplicationJob
  queue_as ENV['SQS_EXPIRED_USER_INVITATION_QUEUE_NAME']

  def perform
    begin
      Rails.logger.info "Starting user status updation for expired invitation ============"

      User.invited.where("activation_token_expire_at < ?", Time.now).find_each do |user|
        user.update_attribute(:status, User::EXPIRED_INVITATION)
        Rails.logger.info "updated status for user ID: #{user.id} <#{user.email}>"
      end

      Rails.logger.info "End of user status updation for expired invitation ============"
    rescue => e
      p "ExpiredUserInvitationJob failed: #{e}"
      Sentry.capture_message("ExpiredUserInvitationJob: #{e.message}")
    end
  end
end
