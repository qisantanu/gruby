class SendKeyToDeveloperJob < ApplicationJob
  queue_as ENV['SQS_SEND_KEY_TO_DEVELOPER_QUEUE_NAME']

  def perform(developer_id)
    Rails.logger.info "Start sending emails of SendKeyToDeveloperJob##{developer_id} key ============"

    developer = Developer.find_by(id: developer_id)

    if developer
      DeveloperMailer.send_account_key(developer).deliver_now
    else
      Rails.logger.info "Developer not found SendKeyToDeveloperJob##{developer_id} ============"  
    end

    Rails.logger.info "Finished sending emails of SendKeyToDeveloperJob##{developer_id} ============"
  end
end
