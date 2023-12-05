# CreateInsuranceCoverage class,  creates the insurance_coverages

class EcxBusinessService::Insurance::CreateCoverage
  include ExtendedInteractor

  def call
    after_check do

      insurance = EcxBusinessService::Insurance.find_by(name: context[:insurance_coverage][:insurance_name])
      insurance_coverage = EcxBusinessService::InsuranceCoverage.new(profile: context[:profile], insurance: insurance)
      insurance_coverage.assign_attributes(field_values: context[:insurance_coverage][:field_values])

      if insurance_coverage.save!
        unless context[:insurance_coverage][:attachments].nil?
          context[:insurance_coverage][:attachments].each do |attachment|
            result = EcxBusinessService::Attachments::Create.call(attachment_type: 'insurances',
                                           file: attachment,
                                           linked_to_id: insurance_coverage.id,
                                           linked_to_type: 'InsuranceCoverage')

            unless result.success?
              context.fail!(message: 'attachment.file_service_error')
            end
          end
        end
        context[:insurance_coverage_ref] = insurance_coverage.try(:to_gid)
      end

    end
  end

  # check if the users and organization are passed to the context and given organization exists in the database
  def check_context
    if !context[:insurance_coverage] || !context[:insurance_coverage][:field_values]
      context.fail!(message: 'profile.insurance_coverage_missing')
    elsif !EcxBusinessService::Insurance.exists?(name: context[:insurance_coverage][:insurance_name])
      context.fail!(message: 'insurance.not_exists')
    elsif !context[:insurance_coverage][:attachments]
      context.fail!(message: 'insurance_coverage.attachments_missing')
    elsif !context[:profile]
      context.fail!(message: 'profile.not_exists')
    end
  end
end
