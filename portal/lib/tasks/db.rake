require 'decryptor'
# require 'active_support/testing/time_helpers'
# include ActiveSupport::Testing::TimeHelpers
require 'profiling'

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Style/StringLiterals, Layout/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength

namespace :db do
  desc "mock data creation"
  task populate_sample_data: :environment do
    PERMISSION_DESCRIPTIONS.each do |name, description|
      Permission.find_or_create_by(name: name, description: description)
    end

    Permission.where.not(name: PERMISSION_DESCRIPTIONS.keys).destroy_all

    PERMISSION_FEATURES.each do |permission, features|
      permission_features = features.map do |feature|
        Feature.find_or_create_by(feature)
      end

      Permission.find_by_name(permission).features = permission_features
    end

    Feature.all.reject { |p| { controller: p.controller, action: p.action}.in?(PERMISSION_FEATURES.values.flatten) }.each(&:destroy)

    CONFIGURATION_TYPES.each do |row|
      if (ConfigurationType.find_by_label(row[:label]).blank?)
        ConfigurationType.create(row)
      end
    end


    OBU_DATAPOINTS.each do |row|
      if (ObuDataPoint.find_by_label(row[:label]).blank?)
        ObuDataPoint.find_or_create_by(row)
      end
    end

    # sample = [7, 30, 90].sample
    # sample_date = Faker::Time.backward(days: sample).in_time_zone
    # travel_to(sample_date) do

    if Developer.count.zero?
      50.times do |i|
        purpose = [].tap do |arr|
          rand(1..5).times do
            arr << ['Mobile APP', 'Website/Portal', 'Research', 'Student Projects', 'Others'].sample
          end
        end
        data = Decryptor.new.encrypt({ submitted_at: Time.now.to_s,
                                       extol_notification: true,
                                       applicant: {
                                        name: "#{ Faker::Name.first_name} #{Faker::Name.last_name}",
                                        email: Faker::Internet.email,
                                        contact: Faker::PhoneNumber.cell_phone,
                                        company: Faker::Company.name },
                                        usage: {
                                          purpose: purpose,
                                          description: Faker::Lorem.paragraphs }}).to_json
        system("curl -X POST '#{ENV['BASE_URL'].to_s + "/api/v1/developers" }' -H 'accept: */*' -H 'x-api-key: #{ ENV["DATAMALL_CLIENT_APP_KEY"] }' -H 'Content-Type: application/json' -d '#{data}'")
      end
    end

    Developer.last(10).each do |developer|
      app_name = Faker::App.name
      bundle_id = "com.qi.#{app_name.parameterize}"
      os_type = ['android', 'ios'].sample
      system("curl -X POST '#{ENV['API_BASE_URL'].to_s + "/api/v1/authenticate" }' -H  'accept: */*' -H  'sdk_account_key: #{developer.sdk_account_key}' -H  'bundle_id: #{bundle_id}' -H  'os_type: #{os_type}' -H  'app_name: #{app_name}'")
    end

    ["maksim.skutin@quantuminventions.com", "supriya.maji@quantuminventions.com", "ramyani.ghosh@quantuminventions.com"].each do |user_email|
      user_name = user_email.split('@').first.split('.').map(&:capitalize).join(' ')
      user = User.find_or_create_by(name: user_name, email: user_email)
      user.permissions = Permission.all
    end
  end

  # Redmine:101881 Developer Migration from DataMall to Management Portal
  # NCS will give us a json file from where we need migrate all the developers to our db
  # This is an one time process
  # We will execute this task from Local machine as of now as we no need to send the mail at that moment
  # To run this, execute: rails db:populate_developer
  desc 'create developer from json file'
  task :populate_developer, [] => [:environment] do |t, args|
    Rails.logger.info('Inside the rake task populate_developer')

    # file_path = Rails.root.join('db/data', 'segmentab.json')
    file_path = Rails.root.join('db/data/prod', 'parent_partitionac.json')
    #file_path = Rails.root.join('db/data/prod', 'b_parent_childab.json')
    #file_path = Rails.root.join('db/data/prod', 'b_parent_childac.json')

    Rails.logger.info "file_path: #{file_path}"
    data = JSON.parse(File.read(file_path))
    Rails.logger.info "length of the file: #{data.length}"

    data.each do |developer|
      Rails.logger.info("Create developer with the values #{developer}")
      contact_number = developer['applicant']['contact']

      if contact_number.blank?
        developer['applicant']['contact'] = '-'
      end

      d = Developer.create_developer(developer)

      if d && developer["extol_notification"] == true
        EmailList.create(email: developer["applicant"]["email"].downcase, email_type: EmailList::TYPE[:developer_migration])
      else
        if d
          Rails.logger.info("Developer created #{developer["applicant"]["email"].downcase}")
        else
          Rails.logger.info("XXXXXXXXX Developer not created #{developer["applicant"]["email"].downcase}")
        end

        email = developer["applicant"]["email"].downcase
        puts email
        Rails.logger.error("========================== #{email}")
      end
    end
  end
end

namespace :file do
  desc 'create obu sample file'
  # To run this, execute: rails file:populate_obu_sample_file
  # change the value of n tomake the file bigger
  task populate_obu_sample_file: :environment do
    profile do
      start_time = Time.now
      n = 100
      ObuDetail.generate_sample_file(n)
      time_taken = Time.now - start_time
      puts "Time taken: #{time_taken} seconds"
    end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength
