require 'decryptor'
require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers

namespace :db do
  desc "mock data creation for past date"
  task populate_sample_old_data: :environment do
     ERROR_STATUS = { ok: 200, conflict: 409, unprocessable_entity: 422 }.freeze


    10.times do
      purpose = [].tap do |arr|
        rand(1..5).times do
          arr << ['Mobile APP', 'Website/Portal', 'Research', 'Student Projects', 'Others'].sample
        end
      end

      sample = [7, 30, 90].sample
      sample_date = Faker::Time.backward(days: sample).in_time_zone
      travel_to(sample_date) do
        developer = Developer.create(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                        email: Faker::Internet.email,
                        contact: Faker::PhoneNumber.cell_phone,
                        company: Faker::Company.name,
                        purpose: purpose,
                        description: Faker::Lorem.paragraph,
                        sdk_account_key: SecureRandom.hex)
        app_name = Faker::App.name
        bundle_id = "com.qi.#{app_name.parameterize}#{Faker::Number.number(digits: 2)}"
        os_type = ['android', 'ios'].sample
        application = Application.create(name: app_name, bundle_id: bundle_id, device_type: os_type)
        application.developers << developer
        device_info = DeviceInfo.create(device_model: "obu-#{Faker::Number.number(digits: 4)}", os_version: "1234")
        ActivationLog.create(developer: developer, application: application, device_info: device_info)
      end
    end
  end
end
