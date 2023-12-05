class EcxBusinessService::CaseStudy < EcxBusinessService::ApplicationRecord
  belongs_to :profile, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id

  CREATE_PARAMS = %w[title duration summary background aim approach outcome client_name phone contact_email client_email profile_legacy_id image_id, key_challenges]
  UPDATE_PARAMS = %w[title duration summary background aim approach outcome client_name phone contact_email client_email, key_challenges]

  after_save :clear_cache
  after_create :clear_cache
  before_destroy :delete_file
  def image
    unless image_id.nil?
      result = Rails.cache.fetch("business/case_study/image/#{image_id}", expires: 24.hours) do
        GetAttachment.call(id: image_id, which: 'file', disposition: nil)
      end

      'data:image/png;base64,' + Base64.encode64(result.attachment) if result.success?
    end
  end

  def delete_file
    result = DeleteAttachment.call(id: image_id) unless image_id.nil?
  end

  def clear_cache
    Rails.cache.delete("business/case_study/image/#{image_id}")
    Rails.cache.delete("business/case_studies/index/#{profile_legacy_id}")
    Rails.cache.delete('business/case_studies/index/all')
  end
end
