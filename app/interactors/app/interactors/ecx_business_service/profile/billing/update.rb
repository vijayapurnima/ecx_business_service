# frozen_string_literal: true

class EcxBusinessService::Profile::Billing::Update
  include Interactor

  def call
    context[:update_params][:profile_legacy_id] = context[:update_params][:profile_id] if context[:update_params][:profile_id].present?
    context[:_profile_billing]           = context[:update_params].select { |p, _v| EcxBusinessService::Profile::Billing::CREATE_PARAMS.include? p }

    context[:profile_billing].assign_attributes(context[:_profile_billing])

    context[:profile_billing].email_verified = false if context[:profile_billing].billing_email_changed?

    if context[:profile_billing].add_new_code?
      context[:profile_billing].assign_attributes(verification_code: EcxBusinessService::Profile::Billing.new_simple_code,
                                                  code_created_at:   Time.now)
    end

    context[:profile_billing].save!

    context[:profile_billing].reload
  end
end
