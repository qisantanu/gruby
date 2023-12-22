# frozen_string_literal: true

class ObuDetailForm
  include ActiveModel::Model

  attr_accessor :vehicle_data

  # Initialize the ObuDetailForm object.
  #
  # @param vehicle_data [Hash]
  # @return [Hash]
  def initialize(vehicle_data)
    @vehicle_data = vehicle_data.with_indifferent_access
  end

  # Process the vehicle_data hash sent during initialization
  #
  # @return [Bool, nil] only nil, true or false
  def process
    obu_detail = ObuDetail.find_by(vehicle_registration_number: vehicle_data['vehicle_number'],
                                   obu_label: vehicle_data['obu_label'])

    # this is for creating fresh ObuDetail
    if obu_detail.blank?
      od = ObuDetail.create(
        vehicle_registration_number: vehicle_data[:vehicle_number],
        obu_label: vehicle_data[:obu_label],
        obu_public_key: vehicle_data[:public_key],
        registered_at: vehicle_data[:created_at]
      )

      if od.persisted?
        Rails.logger.info("ObuDetail created for #{od.vehicle_registration_number}")
        # next # from here we will check for the next vehicle_data
      else
        Rails.logger.info("ObuDetail creation failed for #{vehicle_data[:vehicle_number]}")
        Rails.logger.info("With error: #{od.errors.full_messages.to_sentence}")
      end

      od.persisted?
    end
  end

  # This is for replacing the ObuDetail
  # when the vehicle registration number, is already there
  # and need to update the lable and public key
  #
  # @return [nil]
  def replace
    obu_detail = ObuDetail.find_by(vehicle_registration_number: vehicle_data['vehicle_number'])
    return unless obu_detail.present?

    # should we put the below condition
    obu_detail.obu_label = vehicle_data[:obu_label] if obu_detail.obu_label != vehicle_data[:obu_label]
    obu_detail.obu_public_key = vehicle_data[:public_key] if obu_detail.obu_public_key != vehicle_data[:public_key]

    if obu_detail.save
      Rails.logger.info("ObuDetail replacement successful for #{obu_detail.vehicle_registration_number}")
    else
      Rails.logger.info("ObuDetail repalcement failed for #{vehicle_data[:vehicle_number]}")
    end
  end

  # This is for bulk inserting in ObuDetail model
  #
  # @return [nil], log the reponse in the log for debugging
  def self.bulk_insert(vehicle_data_array)
    obu_attributes_for_new_data = vehicle_data_array.map do |vehicle_data|
      {
        vehicle_registration_number: vehicle_data[:vehicle_number],
        obu_label: vehicle_data[:obu_label],
        obu_public_key: vehicle_data[:public_key],
        registered_at: vehicle_data[:created_at],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }
    end

    response = ObuDetail.insert_all(obu_attributes_for_new_data)
    Rails.logger.info("Bulk insert performed for: #{response.rows.to_s}")
  end
end
