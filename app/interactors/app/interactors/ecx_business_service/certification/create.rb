# CreateCertification class,  creates the certifications

class EcxBusinessService::Certification::Create
  include ExtendedInteractor

  def call
    after_check do
      certificate_type = EcxBusinessService::CertificateType.find_by(name: context[:certificate][:certificate_type][:name])
      certification = EcxBusinessService::Certification.new(profile: context[:profile], certificate_type: certificate_type)
      certification.assign_attributes(expiry_date: context[:certificate][:expiry_date])

      if certification.save!
        unless context[:certificate][:attachments].nil?
          context[:certificate][:attachments].each do |attachment|
            result = EcxBusinessService::Attachments::Create.call(attachment_type: 'certificates',
                                           file: attachment,
                                           linked_to_id: certification.id,
                                           linked_to_type: 'Certification')

            unless result.success?
              context.fail!(message: 'attachment.file_service_error')
            end
          end
        end
        context[:certification_ref] = certification.try(:to_gid)
      end

    end
  end

  # check if the users and organization are passed to the context and given organization exists in the database
  def check_context
    if !context[:certificate]
      context.fail!(message: 'profile.certification_missing')
    elsif !EcxBusinessService::CertificateType.exists?(name: context[:certificate][:certificate_type][:name])
      context.fail!(message: 'certificate_types.not_exists')
    elsif !context[:certificate][:attachments]
      context.fail!(message: 'certification.attachments_missing')
    elsif !context[:profile]
      context.fail!(message: 'profile.not_exists')
    end
  end
end
