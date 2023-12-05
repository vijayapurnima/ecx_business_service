class EcxBusinessService::GroupLevel < EcxBusinessService::ApplicationRecord
  belongs_to :group
  has_many :profile_groups

  before_destroy :update_organization_group

  def update_organization_group
    self.profile_groups.each do |profile_group|
      profile_group.group_level_id = nil
      profile_group.save!
    end
  end

end