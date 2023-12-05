class EcxBusinessService::InsuranceCoverage < EcxBusinessService::ApplicationRecord
  belongs_to :profile, class_name: 'Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  belongs_to :insurance

  before_save :validate_data

  before_destroy :delete_attachments

  def attachments
    result =  EcxBusinessService::Attachments::GetByLinkedTo.call(linked_to_id: id, linked_to_type: 'InsuranceCoverage',
                                          attachment_type: 'insurances')

    result.attachments
  end

  def ins_field_values
    JSON.parse(field_values, symbolize_names: true) unless field_values.nil?
  end

  def delete_attachments
    files = attachments
    files&.each do |file|
      result = EcxBusinessService::Attachments::Delete.call(id: file['id'])
    end
  end

  def validate_data
    field_values = ins_field_values
    errors[:base] << 'Insurance Type is required' if insurance_id.blank?
    field_values.each do |field|
      errors[:base] << "#{field[:name].titleize} is required" if field[:value].blank?
    end
    errors[:base].length > 0 ? (raise ActiveRecord::RecordInvalid, self) : true
  end
end
