class EcxBusinessService::CertificationRedactor

  @global_deny = %w{created_at updated_at}

  @me = EcxBusinessService::Certification.column_names - @global_deny
  @buyer = @me
  @public = %w{}

  def self.redact(certification,access_level)
    return nil if certification.nil?
    redact_specific(certification, access_level)
  end

  def self.redact_specific(certification, access_level)
    return nil if certification.nil?
    certification.readonly!

    case access_level
      when 'me'
        certification.assign_attributes redacted_attributes(@me)
      when 'buyer'
        certification.assign_attributes redacted_attributes(@buyer)
      when 'admin'
        certification.assign_attributes redacted_attributes(@me)
      when 'public'
        certification.assign_attributes redacted_attributes(@public)
      else
        certification.assign_attributes redacted_attributes(@public)
    end

    EcxBusinessService::CertificateTypeRedactor.redact_specific(certification.certificate_type, access_level)

    certification
  end


  def self.redacted_attributes(columns)
    (EcxBusinessService::Certification.column_names - columns).map{|key| [key, nil]}.to_h
  end
end