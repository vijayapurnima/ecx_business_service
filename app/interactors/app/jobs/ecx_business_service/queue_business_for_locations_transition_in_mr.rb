class EcxBusinessService::QueueBusinessForLocationsTransitionInMr < EcxBusinessService::ApplicationJob
  queue_as :default

  def perform(profile)
      addresses = EcxBusinessService::Location.where(profile_legacy_id: profile.legacy_id).pluck(:address)
      begin
      response = RestClient.put(
          SystemConfig.get('mr/host') + "/locations/#{profile.legacy_id}?",
            {
                addresses: addresses
            }
      )
      if response.code != 200
        puts "Locations of BusinessId #{profile.legacy_id} is not updated on MR responses locations"
      else
        puts "Locations of BusinessId #{profile.legacy_id} got updated successfully on MR responses locations"
      end
    rescue RestClient::Exception => exception
      puts "Error occured when tried to update location status in MR service for business_id  #{profile.legacy_id} with exception #{exception.message} response #{exception.response}"
    end
  end


end
