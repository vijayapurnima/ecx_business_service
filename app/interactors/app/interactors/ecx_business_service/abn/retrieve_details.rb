class EcxBusinessService::Abn::RetrieveDetails
  include Interactor

  def call

    # Remove spaces if any
    identifier = context[:identifier]

    if identifier.blank?
      context.fail! message: 'identifier.blank'
    else
      case context[:country][:identifier_name]
      when 'ABN'
        uri = URI('https://abr.business.gov.au/AbrXmlSearch/AbrXmlSearch.asmx/SearchByABNv201408')
      when 'ACN', 'ARBN'
        uri = URI('https://abr.business.gov.au/AbrXmlSearch/AbrXmlSearch.asmx/SearchByASICv201408')
      else
        context.fail!(message: 'error.required_value_missing')
      end

      if uri
        parameters = {searchString: identifier, includeHistoricalDetails: 'N', authenticationGuid: '74085af3-a2ce-4a87-a984-bbc76ecfd4a6'}
        uri.query = URI.encode_www_form(parameters)
        res = Net::HTTP.get_response(uri)
        response = Hash.from_xml(res.body)['ABRPayloadSearchResults']['response']

        unless response['exception'].blank?
          context.fail! message: response['exception']['exceptionDescription']
        else
          abr_name = ''
          if response.key?('businessEntity201408') then
            data = response['businessEntity201408']
            if data['entityType']['entityTypeCode'] == 'IND' then
              legal_name = data['legalName']
              abr_name = [legal_name['familyName'] + ',', legal_name['givenName'], (legal_name['otherGivenName'] || "")].join " "
            elsif !data['mainName'].blank?
              abr_name = data['mainName']['organisationName']
            end
            context[:business_name] = abr_name
          end
        end
      end
    end
  end
end
