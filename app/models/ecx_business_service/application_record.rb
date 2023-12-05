# frozen_string_literal: true

class EcxBusinessService::ApplicationRecord <  ActiveRecord::Base
  self.abstract_class = true
  # TODO: Needs to be fixed

  connects_to database: {
    writing: :ecx_business_service,
    reading: :ecx_business_service
  }
end
