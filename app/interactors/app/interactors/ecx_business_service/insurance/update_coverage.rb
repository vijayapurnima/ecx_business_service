
# UpdateInsuranceCoverage class,  updates the insurance_coverages

class EcxBusinessService::Insurance::UpdateCoverage
  include ExtendedInteractor

  def call
    after_check do

      insurance_coverage = EcxBusinessService::InsuranceCoverage.find(context[:insurance_coverage][:id])
      insurance_coverage.assign_attributes(field_values: context[:insurance_coverage][:field_values])
      insurance_coverage.save!

      unless context[:insurance_coverage][:attachments].nil?
        context[:insurance_coverage][:attachments].each do |attachment|
          result = EcxBusinessService::Attachments::Create.call(attachment_type: 'insurances',
                                         file: attachment,
                                         linked_to_id: context[:insurance_coverage][:id],
                                         linked_to_type: 'InsuranceCoverage')

          unless result.success?
            context.fail!(message: 'attachment.file_service_error')
          end
        end
      end
    end
  end

  # check if the users and organization are passed to the context and given organization exists in the database
  def check_context
    if !context[:insurance_coverage]
      context.fail!(message: 'profile.insurance_coverage_missing')
    elsif !EcxBusinessService::InsuranceCoverage.exists?(id:context[:insurance_coverage][:id])
      context.fail!(message: 'insurance_coverage.not_exists')
    end
  end
end
