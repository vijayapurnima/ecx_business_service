require 'rest-client'

class EcxBusinessService::Attachments::GetByLinkedTo
  include ExtendedInteractor

  SERVICE_NAME = 'EconomX'


  def call
    after_check do
      begin
        response = RestClient.get(
          SystemConfig.get('file/host') + "/attachments?service_name=#{SERVICE_NAME}&linked_to_id=#{context[:linked_to_id]}&linked_to_type=#{context[:linked_to_type]}&attachment_type=#{context[:attachment_type]}"
        )
        if response.code == 200
          context[:attachments] = JSON.parse(response)
        end
      rescue RestClient::Exception => exception
        puts exception.message, exception.response
        Sentry.capture_exception(exception)
        context.fail!(message: 'attachment.file_service_error')
      end
    end
  end

  def check_context
    if !context[:linked_to_id] || !context[:linked_to_type]
      context.fail!(message: 'attachment.missing_linked_to_details')
    end
  end
end
