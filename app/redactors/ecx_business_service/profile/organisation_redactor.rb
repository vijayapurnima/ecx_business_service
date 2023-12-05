class EcxBusinessService::Profile::OrganisationRedactor
  @global_deny = %w[created_at]

  @me     = EcxBusinessService::Profile::Organisation.column_names - @global_deny
  @public = %w[
    id
    legacy_id
    logo_id
    abn
    abr_name
    trading_name
    year_founded
    description
    ownership_type
    registration_contact
    public_profile
    public_profile_path
    website
  ]

  @buyer  = %w[
    id
    legacy_id
    logo_id
    abr_name
    trading_name
    capability_statement_id
    size
    website
    year_founded
    description
    ownership_type
    registration_contact
    market_alignment
    atsi_owned
    atsi_operated
    disability_enterprise
    public_profile
    public_profile_path
  ]

  @edo = %w[
    id
    legacy_id
    logo_id
    abr_name
    trading_name
    size
    website
    year_founded
    description
    ownership_type
  ]

  def self.redact(profile, access_level)
    return nil if profile.nil?

    redact_specific(profile, access_level)
  end

  def self.redact_specific(profile, access_level)
    return nil if profile.nil?

    profile.readonly!
    # Raven.extra_context({profile: profile.attributes, columns: Profile.column_names})

    case access_level # If you add a new access_level, you need to update the profile cache clear method, in the Profile model
    when 'me'
      profile.assign_attributes redacted_attributes(@me)
    when 'buyer'
      profile.assign_attributes redacted_attributes(@buyer)
    when 'edo'
      profile.assign_attributes redacted_attributes(@edo)
    when 'admin'
      profile.assign_attributes redacted_attributes(@me)
    when 'public'
      profile.assign_attributes redacted_attributes(@public)
    else
      profile.assign_attributes redacted_attributes(@public)
    end
    profile.insurance_coverages.each do |ic|
      EcxBusinessService::Insurance::CoverageRedactor.redact_specific(ic, access_level)
    end
    profile.certifications.each do |ic|
      EcxBusinessService::CertificationRedactor.redact_specific(ic, access_level)
    end
    profile
  end

  def self.redacted_attributes(columns)
    (EcxBusinessService::Profile::Organisation.column_names - columns).map { |key| [key, nil] }.to_h
  end
end
