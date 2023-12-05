class EcxBusinessService::Groups::CreateGroup
  include ExtendedInteractor

  def call
    after_check do
      group = EcxBusinessService::Group.create(name: context[:group_params][:name],
                           expansion: context[:group_params][:expansion])

      if context[:group_params][:levels]
        context[:group_params][:levels].each do |level|
          group_level = EcxBusinessService::GroupLevel.create(group: group, level: level[:level], priority: level[:priority])
        end
      end

      context[:group_ref] = group.try(:to_gid)
    end
  end

  def check_context
    if !context[:group_params]
      context.fail!(message: "Group params missing")
    elsif !context[:group_params][:name]
      context.fail!(message: "Group Name missing")
    end
  end
end
