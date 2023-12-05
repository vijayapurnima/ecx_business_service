require 'rest-client'

class EcxBusinessService::CaseStudy::Update
  include ExtendedInteractor

  def call
    after_check do
      if context[:case_study_params][:image] &&
          context[:case_study_params][:image].class == ActionDispatch::Http::UploadedFile
        result = EcxBusinessService::Attachments::Create.call(id: context[:case_study].image_id,
                                       attachment_type: 'case_study',
                                       file: context[:case_study_params][:image],
                                       linked_to_id: context[:case_study].id,
                                       linked_to_type: 'CaseStudy')

        if result.success?
          context[:case_study].image_id = result.attachment['id'] if context[:case_study].image_id.nil?
        end
      end

      context[:case_study].assign_attributes(context[:case_study_params].select{|p, v| EcxBusinessService::CaseStudy::UPDATE_PARAMS.include? p})
      context[:case_study].save!
    end
  end

  def check_context
    if !context[:case_study] || !context[:case_study_params]
      context.fail!(message: "error.required_value_missing")
    end
  end
end