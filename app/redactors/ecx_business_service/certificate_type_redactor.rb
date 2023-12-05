class EcxBusinessService::CertificateTypeRedactor
  @global_deny = %w{created_at updated_at}

  @me = EcxBusinessService::CertificateType.column_names - @global_deny
  @buyer = @me
  @public = %w{
    id
    name
  }

  def self.redact(certificate_type,access_level)
    return nil if certificate_type.nil?
    redact_specific(certificate_type, access_level)
  end

  def self.redact_specific(certificate_type, access_level)
    return nil if certificate_type.nil?
    certificate_type.readonly!

    case access_level
      when 'me'
        certificate_type.assign_attributes redacted_attributes(@me)
      when 'buyer'
        certificate_type.assign_attributes redacted_attributes(@buyer)
      when 'admin'
        certificate_type.assign_attributes redacted_attributes(@me)
      when 'public'
        certificate_type.assign_attributes redacted_attributes(@public)
      else
        certificate_type.assign_attributes redacted_attributes(@public)
    end
    certificate_type
  end


  def self.redacted_attributes(columns)
    (EcxBusinessService::CertificateType.column_names - columns).map{|key| [key, nil]}.to_h
  end

end