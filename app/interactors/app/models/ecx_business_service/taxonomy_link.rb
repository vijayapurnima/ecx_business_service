class EcxBusinessService::TaxonomyLink < EcxBusinessService::ApplicationRecord
  belongs_to :taxonomy
  belongs_to :owner, polymorphic: true
end
