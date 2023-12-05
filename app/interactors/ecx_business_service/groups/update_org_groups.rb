class EcxBusinessService::Groups::UpdateOrgGroups
  include ExtendedInteractor

  def call
    after_check do
      # check if an organization_group already exists each group
      context[:group_params].each do |group|
        # get the group
        grp = EcxBusinessService::Group.find(group[:id])
        # Check if a membership exists for the given group and organization
        if EcxBusinessService::Profile::Group.exists?(group: grp, profile: context[:profile])
          # Get the membership
          membership = EcxBusinessService::Profile::Group.find_by(group: grp, profile: context[:profile])
          # if the group membership is removed by the user
          if group[:is_member] == 'false'
            membership.destroy
          elsif (!membership.group_level.nil? && (membership.group_level.level != group[:org_level])) || membership.group_level.nil?
            # otherwise update level if level is changed
            if group[:org_level]
              membership.group_level = EcxBusinessService::GroupLevel.find_by(group: grp, level: group[:org_level])
              membership.save!
            end
          end
          # Create a new membership if group is selected
        elsif group[:is_member] == 'true'
          EcxBusinessService::Profile::Group.create!(group: grp, profile: context[:profile], group_level: EcxBusinessService::GroupLevel.find_by(group: grp, level: group[:org_level][:level]))
        end
      end
    end
  end

  # check if the organization is passed to the context and an organization exists with it
  def check_context
    if !context[:profile] || !EcxBusinessService::Profile::Organisation.exists?(id: context[:profile][:id])
      context.fail!(message: 'profile.not_exists')
    end
  end
end
