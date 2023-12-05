class EcxBusinessService::Profile::Group < EcxBusinessService::ApplicationRecord
  belongs_to :profile, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  belongs_to :group, class_name: 'EcxBusinessService::Group'
  belongs_to :group_level, class_name: 'EcxBusinessService::GroupLevel'
end
