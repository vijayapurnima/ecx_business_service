# frozen_string_literal: true

class EcxBusinessService::Profile::Billing::VerifyEmail
  include Interactor

  def call
    puts "context", context
    profile_billing = EcxBusinessService::Profile::Billing.find_by(verification_code: context[:code], billing_email: context[:billing_email])

    if profile_billing.nil?
      context.fail!(message: 'Not Found', code: :not_found)
    elsif profile_billing.code_expired?
      context.fail!(message: 'Verfication code expired', code: :unprocessable_entity)
    else
      profile_billing.assign_attributes(
        verification_code: nil,
        code_created_at:   nil,
        email_verified:    true
      )

      profile_billing.save!
      profile_billing.reload
    end
  end
end
