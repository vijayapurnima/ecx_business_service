class EcxBusinessService::Country < EcxBusinessService::ApplicationRecord
  has_many :country_identifiers

  after_save :clear_cache
  after_create :clear_cache

  private

  def clear_cache
    Rails.cache.delete('countries/country_identifiers')
  end
end
