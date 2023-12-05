class EcxBusinessService::Insurance::Redactor

  @global_deny = %w{created_at updated_at}

  @me = EcxBusinessService::Insurance.column_names - @global_deny
  @public = %w{
      id
      name
      fields
  }

  def self.redact(insurance,access_level)
    return nil if insurance.nil?
    redact_specific(insurance, access_level)
  end

  def self.redact_specific(insurance, access_level)
    return nil if insurance.nil?
    insurance.readonly!

    case access_level
      when 'me'
        insurance.assign_attributes redacted_attributes(@me)
      when 'buyer'
        insurance.assign_attributes redacted_attributes(@public)
      when 'admin'
        insurance.assign_attributes redacted_attributes(@me)
      when 'public'
        insurance.assign_attributes redacted_attributes(@public)
      else
        insurance.assign_attributes redacted_attributes(@public)
    end
    insurance
  end


  def self.redacted_attributes(columns)
    (EcxBusinessService::Insurance.column_names - columns).map{|key| [key, nil]}.to_h
  end
end