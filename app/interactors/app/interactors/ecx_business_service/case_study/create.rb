class EcxBusinessService::CaseStudy::Create
  include ExtendedInteractor

  def call
    after_check do
      context[:case_study] = EcxBusinessService::CaseStudy.new(context[:case_study_params].select {|p, v| EcxBusinessService::CaseStudy::CREATE_PARAMS.include? p.try(:to_s)})
      context[:case_study][:profile_legacy_id]=context[:case_study_params][:profile_id] if context[:case_study_params][:profile_id].present?
      if context[:case_study].save!
        context[:case_study].reload
        unless context[:case_study_params][:image].nil?
          result = EcxBusinessService::Attachments::Create.call(attachment_type: 'case_study',
                                         file: context[:case_study_params][:image],
                                         linked_to_id: context[:case_study].id,
                                         linked_to_type: 'CaseStudy')

          if result.success?
            context[:case_study].image_id = result.attachment['id']
            context[:case_study].save!
          end
        end
      else
        context.fail!(message: context[:case_study].errors)
      end
    end
  end

  def check_context
    if !context[:case_study_params]
      context.fail!(message: "error.required_value_missing")
    end
  end
end