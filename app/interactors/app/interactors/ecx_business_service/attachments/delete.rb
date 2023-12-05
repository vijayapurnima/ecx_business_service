require 'rest-client'

class EcxBusinessService::Attachments::Delete
  include ExtendedInteractor

  def call
    after_check do
      begin
        response = RestClient.delete(
            SystemConfig.get('file/host') + "/attachments/#{context[:id]}?service_name=#{ApplicationController::SERVICE_NAME}"
        )
        if response.code == 200

        end
      rescue RestClient::Exception => exception
        puts exception.message, exception.response
        Sentry.capture_exception(exception)
        context.fail!(message: 'attachment.file_service_error')
      end
    end
  end

  def check_context
    if !context[:id]
      context.fail!(message: 'attachment.missing_identifier')
    end
  end
end
