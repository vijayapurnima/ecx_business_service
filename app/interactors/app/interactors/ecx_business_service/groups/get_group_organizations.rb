class EcxBusinessService::Groups::GetGroupOrganizations
  include Interactor

  def call
    if context[:with_organisation]
      context[:profiles] = EcxBusinessService::Profile::Organisation.only_active.joins(:profile_groups).where('profile_groups.group_id': context[:group].id)
      context[:group_levels] = EcxBusinessService::Profile::Group.joins(:group_level).where(group_id: context[:group].id).pluck(:profile_legacy_id, :'group_levels.id',:'group_levels.level', :'group_levels.priority').map{ |arr| [arr[0], {'id':arr[1],'level': arr[2], 'priority': arr[3]}] }.to_h
    end
  end
end
