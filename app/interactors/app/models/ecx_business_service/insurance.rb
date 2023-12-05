class EcxBusinessService::Insurance < EcxBusinessService::ApplicationRecord


  after_create :clear_cache
  after_save :clear_cache


  private

  def clear_cache
    Rails.cache.delete("business/insurances/all")
    Rails.cache.delete("business/insurances/#{self.id}")
  end

end
