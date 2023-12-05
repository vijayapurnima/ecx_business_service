require 'rest-client'

class EcxBusinessService::Attachments::GetById
  include ExtendedInteractor

  def call
    after_check do
      begin
        response = RestClient.get(
            SystemConfig.get('file/host') + "/attachments/#{context[:id]}?service_name=#{ApplicationController::SERVICE_NAME}&which=#{context[:which]}&disposition=#{context[:disposition] || 'attachment'}&with_resize=#{context[:with_resize] || false}"
        )
        if response.code == 200
          case context[:which]
            when 'details'
              context[:attachment] = JSON.parse(response)
            when 'file'
              context[:attachment] = response.body
          end

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
