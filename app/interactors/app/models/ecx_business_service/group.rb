require 'base64'

class EcxBusinessService::Group < EcxBusinessService::ApplicationRecord
  # has_many :organizations, through: :organization_groups
  has_many :profile_groups, dependent: :destroy
  has_many :group_levels, dependent: :destroy

  after_save :clear_cache
  after_create :clear_cache

  validates_uniqueness_of :name

  def logo
    if !self.logo_id.nil?
      result = EcxBusinessService::Attachments::GetById.call(id: self.logo_id, which: 'file', disposition: nil, with_resize: true)
      if result.success?
        'data:image/png;base64,' + Base64.encode64(result.attachment)
      end
    else
      'data:image/png;base64,' + Base64.encode64(File.read(File.join(Rails.root,'app/assets/images/logo_placeholder.jpg')))
    end
  end

  def levels
    self.group_levels.map{|lv| lv.slice(:id,:group_id,:level,:priority)}
  end

  private

  def clear_cache
    Rails.cache.delete("business/groups/index/admin")
    Rails.cache.delete("business/groups/groups_levels/#{self.id}")
    Rails.cache.delete("business/groups/members/#{self.id}")
    Rails.cache.delete("business/groups/members/#{self.id}/with_organization")
    Rails.cache.delete("business/groups/show/#{self.id}")
    Rails.cache.delete("business/groups/show/#{self.id}/with_organization")
    Rails.cache.delete("business/groups/set_group/#{self.id}")
    Rails.cache.delete("business/groups/set_group/#{self.name}/by_name")
  end

end