# frozen_string_literal: true

# CreateOrganisation class, creates a profile

class EcxBusinessService::Profile::CreateOrganisation
  include ExtendedInteractor

  def call
    after_check do
      # remove the attributes that will be saved separately from context[:organization]
      context[:_profile] = context[:organization].select { |p, _v| EcxBusinessService::Profile::Organisation::CREATE_PARAMS.include? p }

      # Create a new instance of profile from context[:_profile]
      profile = EcxBusinessService::Profile::Organisation.new(context[:_profile])

      profile.legacy_id = context[:organization][:id] unless context[:organization][:id].nil?

      # save the org and create a membership for the current_user on it
      if profile.save!
        profile.reload

        result = EcxBusinessService::Profile::UpdateOrganisation.call(profile: profile, org_params: context[:organization], section_type: 'profile')

        if result.success?
          context[:organization] = result.profile
          context[:organization][:id] = result.profile.legacy_id

        else
          context.fail!(message: result.message)
        end
      end
    end
  end

  def check_context
    # Add a check to see if current user exists and organization (to be created) is passed to the context
    if !context[:organization] || context[:organization].blank?
      context.fail!(message: 'missing parameters')
    elsif context[:organization][:country_identifiers].length.zero? ||
          context[:organization][:country_identifiers].any? { |ci| !ci[:country_id] || !EcxBusinessService::Country.exists?(ci[:country_id]) }
      context.fail!(message: 'identifier.country_missing')
    elsif !context[:current_user] || context[:current_user].blank?
      context.fail!(message: 'auth.no_token')
    end
  end
end
