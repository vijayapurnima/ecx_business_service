class EcxBusinessService:: ProductService::Create
  include ExtendedInteractor

  def call
    after_check do
      context[:product_service_params][:profile_legacy_id] = context[:product_service_params][:profile_id] if context[:product_service_params][:profile_id].present?
      context[:product_service]                    = EcxBusinessService::ProductService.new(context[:product_service_params].select do |p, _v|
                                                                          EcxBusinessService::ProductService::CREATE_PARAMS.include? p.try(:to_s)
                                                                        end)

      if context[:product_service].save!
        context[:product_service].reload
        unless context[:product_service_params][:promo_image].nil?
          result = EcxBusinessService::Attachments::Create.call(attachment_type: 'product_service_image',
                                         file:            context[:product_service_params][:promo_image],
                                         linked_to_id:    context[:product_service].id,
                                         linked_to_type:  'ProductService')

          if result.success?
            context[:product_service].promo_image_id = result.attachment['id']
            context[:product_service].save!
          end
        end

        unless context[:product_service_params][:files].nil?
          context[:product_service_params][:files].each do |file|
            result = EcxBusinessService::Attachments::Create.call(attachment_type: 'product_service_document',
                                           file:            file,
                                           linked_to_id:    context[:product_service].id,
                                           linked_to_type:  'ProductService')

            context.fail!(message: 'attachment.file_service_error') unless result.success?
          end
        end
      else
        context.fail!(message: context[:product_service].errors)
      end
    end
  end

  def check_context
    context.fail!(message: 'error.required_value_missing') unless context[:product_service_params]
  end
end
