# frozen_string_literal: true

class EcxBusinessService::Profile::Billing < EcxBusinessService::ApplicationRecord
  belongs_to :profile, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id

  CREATE_PARAMS             = %w[billing_email email_verified currency phone address profile_legacy_id]

  def self.new_simple_code
    # Allow alphanumerics minus a few ambiguous characters
    range = [*('0'..'9'), *('A'..'Z')] - %w[8 B C D I O 0 Q 1]
    # Select 8 random characters from valid range
    (0..7).map { range.sample }.join
  end

  def code_expired?
    code_created_at <= (Time.now - 72.hours) if verification_code && code_created_at
  end

  def is_complete?
    valid? && email_verified
  end

  def add_new_code?
    email_verified ? false : ((verification_code.present? && code_expired?) || !verification_code.present?)
  end
end
