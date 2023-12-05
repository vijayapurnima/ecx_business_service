
# UpdateCertification class,  updates the certifications

class EcxBusinessService::Certification::Update
  include ExtendedInteractor

  def call
    after_check do
      certification = EcxBusinessService::Certification.find(context[:certificate][:id])
      certification.assign_attributes(expiry_date: context[:certificate][:expiry_date])
      certification.save!
      unless context[:certificate][:attachments].nil?
        context[:certificate][:attachments].each do |attachment|
          result = EcxBusinessService::Attachments::Create.call(attachment_type: 'certificates',
                                         file: attachment,
                                         linked_to_id: context[:certificate][:id],
                                         linked_to_type: 'Certification')

          unless result.success?
            context.fail!(message: 'attachment.file_service_error')
          end
        end
      end

    end
  end

  # check if the users and organization are passed to the context and given organization exists in the database
  def check_context
    if !context[:certificate]
      context.fail!(message: 'profile.certification_missing')
    elsif !EcxBusinessService::Certification.exists?(id:context[:certificate][:id])
      context.fail!(message: 'certification.not_exists')
    end
  end
end
