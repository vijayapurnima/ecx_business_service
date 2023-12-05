# frozen_string_literal: true

class EcxBusinessService::Profile::Billing::Create
  include Interactor

  def call
    context[:_profile_billing] = context[:billing_params].select { |p, _v| EcxBusinessService::Profile::Billing::CREATE_PARAMS.include? p.to_s }

    context[:profile_billing] = EcxBusinessService::Profile::Billing.find_by(profile_legacy_id: context[:_profile_billing][:profile_legacy_id])

    if context[:profile_billing].nil?
      context[:profile_billing] = EcxBusinessService::Profile::Billing.new(context[:_profile_billing])

      if context[:profile_billing].add_new_code?
        context[:profile_billing].assign_attributes(verification_code: EcxBusinessService::Profile::Billing.new_simple_code,
                                                    code_created_at:   Time.now)
      end
      
      context[:profile_billing].save
      context[:profile_billing].reload
    else
      EcxBusinessService::Profile::Billing::Update.call(profile_billing: context[:profile_billing], update_params: context[:_profile_billing])
    end
  end
end
