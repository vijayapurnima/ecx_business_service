class EcxBusinessService::CertificateType < EcxBusinessService::ApplicationRecord


  after_create :clear_cache
  after_save :clear_cache


  private

  def clear_cache
    Rails.cache.delete("business/certificate_types/all")
    Rails.cache.delete("business/certificate_types/#{self.id}")
  end
end
