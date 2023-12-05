class EcxBusinessService::Insurance::CoverageRedactor

  @global_deny = %w{created_at updated_at}

  @me = EcxBusinessService::InsuranceCoverage.column_names - @global_deny
  @public = %w{}
  @buyer = @me

  def self.redact(insurance_coverage,access_level)
    return nil if insurance_coverage.nil?
    redact_specific(insurance_coverage, access_level)
  end

  def self.redact_specific(insurance_coverage, access_level)
    return nil if insurance_coverage.nil?
    insurance_coverage.readonly!

    case access_level
      when 'me'
        insurance_coverage.assign_attributes redacted_attributes(@me)
      when 'buyer'
        insurance_coverage.assign_attributes redacted_attributes(@buyer)
      when 'admin'
        insurance_coverage.assign_attributes redacted_attributes(@me)
      when 'public'
        insurance_coverage.assign_attributes redacted_attributes(@public)
      else
        insurance_coverage.assign_attributes redacted_attributes(@public)
    end
    EcxBusinessService::Insurance::Redactor.redact_specific(insurance_coverage.insurance, access_level)

    insurance_coverage
  end


  def self.redacted_attributes(columns)
    (EcxBusinessService::InsuranceCoverage.column_names - columns).map{|key| [key, nil]}.to_h
  end
end