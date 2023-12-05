class EcxBusinessService::Profile::VerifyExistence
  include ExtendedInteractor

  def call
    after_check do
      if context[:identifier] && EcxBusinessService::CountryIdentifier.exists?(identifier: context[:identifier], country_id: context[:country_id])
        context[:profile] = EcxBusinessService::CountryIdentifier.find_by(identifier: context[:identifier], country_id: context[:country_id]).profile
      else
        context.fail!(message: 'profile.not_exists')
      end
    end
  end

  def check_context
    if !context[:country_id] || (context[:identifier_name] && !EcxBusinessService::Country.exists?(context[:country_id]))
      context.fail!(message: 'identifier.country_missing')
    end
  end
end
