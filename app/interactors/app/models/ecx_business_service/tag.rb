class EcxBusinessService::Tag < EcxBusinessService::ApplicationRecord
  belongs_to :profile, optional: true, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, :primary_key => :legacy_id
  belongs_to :category

  after_save :clear_cache
  after_create :clear_cache
  before_destroy :clear_cache

  def clear_cache
    Rails.cache.delete("business/tags_list")
    Rails.cache.delete("business/tags_list/#{self.profile_legacy_id}")
    Rails.cache.delete("business/profile_tags/#{self.profile_legacy_id}")
  end
end
