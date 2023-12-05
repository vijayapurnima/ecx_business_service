class EcxBusinessService::Taxonomy < EcxBusinessService::ApplicationRecord

  def ancestor_keys
    Rails.cache.fetch("taxonomy/records/#{id}", expires_in: 1.month) do
      ["#{key} - #{name}"] + (EcxBusinessService::Taxonomy.find_by_key(parent).try(:ancestor_keys) || [])
    end
  end

end
