class EcxBusinessService::ProductService < EcxBusinessService::ApplicationRecord
  belongs_to :profile, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id

  validates :product_type, inclusion: { in: %w[product service] }
  validates :status,
            inclusion: { in: ['Concept phase', 'Research & Development', 'Market Testing', 'Feasibility study',
                              'Design and development', 'Testing & verification', 'Manufacturing', 'Product launched', 'Product Improvement', 'Market growth'] }

  after_save :clear_cache
  after_create :clear_cache
  before_destroy :delete_file, :delete_attachments

  CREATE_PARAMS = %w[name product_type description status promo_link promo_video profile_legacy_id]
  UPDATE_PARAMS = %w[name product_type description status promo_link promo_video]

  def promo_image
    unless promo_image_id.nil?
      result = Rails.cache.fetch("business/product_services/promo_image/#{promo_image_id}", expires: 24.hours) do
        GetAttachment.call(id: promo_image_id, which: 'file', disposition: nil)
      end

      'data:image/png;base64,' + Base64.encode64(result.attachment) if result.success?
    end
  end

  def attachments
    result = GetAttachmentByLinkedTo.call(linked_to_id: id, linked_to_type: 'ProductService',
                                          attachment_type: 'product_service_document')

    result.attachments
  end

  def delete_attachments
    files = attachments
    files&.each do |file|
      result = DeleteAttachment.call(id: file['id'])
    end
  end

  def delete_file
    result = DeleteAttachment.call(id: promo_image_id) unless promo_image_id.nil?
  end

  def clear_cache
    Rails.cache.delete("business/product_services/document/#{document_id}")
    Rails.cache.delete("business/product_services/promo_image/#{promo_image_id}")
    Rails.cache.delete("business/product_services/index/#{profile_legacy_id}")
  end
end
