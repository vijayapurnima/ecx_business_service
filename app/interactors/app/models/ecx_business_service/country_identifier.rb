class EcxBusinessService::CountryIdentifier < EcxBusinessService::ApplicationRecord
  belongs_to :country
  belongs_to :profile, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id
end
