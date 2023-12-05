# CreateAttachment class, creates a new attachment
require 'rest-client'

class EcxBusinessService::Attachments::Create
  include ExtendedInteractor

  def call
    after_check do
      begin
        response = RestClient.post(
            SystemConfig.get('file/host') + "/attachments?service_name=#{ApplicationController::SERVICE_NAME}",
            {
                file: {
                    id: context[:id] || nil,
                    attachment_type: context[:attachment_type],
                    original_name: context[:file].original_filename,
                    mime_type: context[:file].content_type,
                    extension: File.extname(context[:file].original_filename),
                    data: context[:file].read,
                    linked_to_id: context[:linked_to_id],
                    linked_to_type: context[:linked_to_type],
                    service_name: ApplicationController::SERVICE_NAME,
                    size: context[:file].size
                }
            }
        )
        if response.code == 200
          context[:attachment] = JSON.parse(response)
        end
      rescue RestClient::Exception => exception
        puts exception.message, exception.response
        Sentry.capture_exception(exception)
        context.fail!(message: 'attachment.file_service_error')
      end
    end
  end

  def check_context
    if !context[:file] || !context[:attachment_type]
      context.fail!(message: 'attachment.missing_details')
    end
  end
end