
class EcxBusinessService::ProductService::Update
  include ExtendedInteractor

  def call
    after_check do
      if context[:product_service_params][:promo_image] &&
         context[:product_service_params][:promo_image].instance_of?(ActionDispatch::Http::UploadedFile)
        result = EcxBusinessService::Attachments::Create.call(id: context[:product_service].promo_image_id,
                                       attachment_type: 'product_service_image',
                                       file: context[:product_service_params][:promo_image],
                                       linked_to_id: context[:product_service].id,
                                       linked_to_type: 'ProductService')

        if result.success? && context[:product_service].promo_image_id.nil?
          context[:product_service].promo_image_id = result.attachment['id']
        end
      end

      unless context[:product_service_params][:files].nil?
        context[:product_service_params][:files].each do |file|
          result = EcxBusinessService::Attachments::Create.call(attachment_type: 'product_service_document',
                                         file: file,
                                         linked_to_id: context[:product_service].id,
                                         linked_to_type: 'ProductService')

          context.fail!(message: 'attachment.file_service_error') unless result.success?
        end
      end

      unless context[:product_service_params][:documents].nil?
        context[:product_service_params][:documents].each do |document|
          next unless document[:destroy] === 'true'

          result = EcxBusinessService::Attachments::Delete.call(id: document[:id])

          context.fail!(message: 'attachment.file_service_error') unless result.success?
        end
      end

      context[:product_service].assign_attributes(context[:product_service_params].select do |p, _v|
                                                    EcxBusinessService::ProductService::UPDATE_PARAMS.include? p
                                                  end)
      context[:product_service].save!
    end
  end

  def check_context
    if !context[:product_service] || !context[:product_service_params]
      context.fail!(message: 'error.required_value_missing')
    end
  end
end
