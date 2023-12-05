class EcxBusinessService::Certification < EcxBusinessService::ApplicationRecord
  belongs_to :profile, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  belongs_to :certificate_type

  before_save :validate_data
  before_destroy :delete_attachments

  def attachments
    result = EcxBusinessService::Attachments::GetByLinkedTo.call(linked_to_id: id, linked_to_type: 'Certification',
                                          attachment_type: 'certificates')

    result.attachments
  end

  def delete_attachments
    files = attachments
    files&.each do |file|
      result = EcxBusinessService::Attachments::Delete.call(id: file['id'])
    end
  end
  
  def validate_data
    errors[:base] << 'Expiry Date is required' if expiry_date.blank?
    errors[:base] << 'Certificate Type is required' if certificate_type_id.blank?
    errors[:base].length > 0 ? (raise ActiveRecord::RecordInvalid, self) : true
  end
end
