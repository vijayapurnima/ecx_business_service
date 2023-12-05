# frozen_string_literal: true

class EcxBusinessService::Profile::Billing::SetEmailCode
  include Interactor

  def call
    if context[:profile_billing].add_new_code?
      context[:profile_billing].assign_attributes(verification_code: EcxBusinessService::Profile::Billing.new_simple_code, code_created_at: Time.now)

      context[:profile_billing].save!

      context[:profile_billing].reload
    end
  end
end
