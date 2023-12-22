#
# This job will be executed manually by the MP developers who has access
# This job will help to execute specific rake task
#
class TaskRunnerJob < ApplicationJob
  queue_as ENV['SQS_TASK_RUNNER_QUEUE_NAME']

  # We will trigger this job manually
  # This job will execute the rake task which will be passed as a parameter
  # @param rake_task [String] string name of the task, example: 'db:populate_developer'
  def perform(rake_task)
    Rails.logger.info "Start triggering the rake task##{rake_task}============"

    system('rails', rake_task)
    Rails.logger.info "Finished rake task #{rake_task}============"
  end
end
