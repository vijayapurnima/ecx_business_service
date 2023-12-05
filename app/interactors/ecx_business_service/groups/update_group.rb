class EcxBusinessService::Groups::UpdateGroup
  include ExtendedInteractor

  def call
    after_check do
      context[:group].assign_attributes(expansion: context[:group_params][:expansion], logo_id: context[:group_params][:logo_id])

      context[:group].save!

      if context[:group_params][:levels] && context[:group_params][:levels].length > 0
        context[:group_params][:levels].each do |level|
          group_level= EcxBusinessService::GroupLevel.find_by(group_id: context[:group_params][:id], level: level[:level], priority: level[:priority])
          if level[:id].nil? && group_level.nil?
            EcxBusinessService::GroupLevel.create(group: context[:group], level: level[:level], priority: level[:priority])
          elsif level[:destroy]
            EcxBusinessService::GroupLevel.find(level[:id]).try(:destroy)
          else
            group_level = EcxBusinessService::GroupLevel.find(level[:id])
            group_level.assign_attributes(level: level[:level], priority: level[:priority])
            group_level.save!
          end
        end
      end

      if context[:group_params][:organizations] && context[:group_params][:organizations].length > 0
        context[:group_params][:organizations].each do |member|
          unless member[:id].nil?
            if member[:destroy]
              EcxBusinessService::Profile::Group.find_by(profile_legacy_id: member[:id], group_id: context[:group_params][:id]).try(:destroy!)
            else
              @group_level = EcxBusinessService::GroupLevel.find_by(group_id: context[:group_params][:id], level: member[:group_level][:level])
              organization_group = EcxBusinessService::Profile::Group.find_by(profile_legacy_id: member[:id], group_id: context[:group_params][:id])
              if organization_group.nil?
                EcxBusinessService::Profile::Group.create(profile_legacy_id: member[:id], group_id: context[:group_params][:id], group_level_id: @group_level[:id])
              else
                organization_group.assign_attributes(group_level_id: @group_level[:id])
                organization_group.save!
              end
            end
          end
        end
      end
    end
  end

  def check_context
    if !context[:group]
      context.fail!(message: "Group doesn't exist")
    elsif !context[:group_params]
      context.fail!(message: "Group params missing")
    end
  end
end
