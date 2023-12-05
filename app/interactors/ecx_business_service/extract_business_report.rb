class  EcxBusinessService::ExtractBusinessReport
  include ExtendedInteractor

  def call
      org_set = context[:org_set] || EcxBusinessService::Profile::Organisation.all
      orgs = org_set.eager_load(:locations, :taxonomies, country_identifiers: :country).map{ |org| org.attributes.slice('legacy_id', 'trading_name', 'atsi_owned', 'atsi_operated', 'created_at').merge(taxonomies: (org.taxonomies.map(&:ancestor_keys) || []), locations: (org.locations.map(&:attributes) || []), country_identifiers: (org.country_identifiers.map{ |ci| [ci.country.name, ci.country.identifier_name, ci.identifier] } || []))}
      taxonomy_count = orgs.select{ |org| org[:taxonomies].present? }.map { |a| a[:taxonomies].count }.max || 0
      taxonomy_parent_count = orgs.select{ |org| org[:taxonomies].present? }.map { |a| a[:taxonomies].map(&:count).max }.max || 0
      location_count = orgs.map { |a| a[:locations].count }.max || 0
      ci_count = orgs.map { |a| a[:country_identifiers].count }.max || 0
      orgs = orgs.map do |org|

        org['created_at'] = org['created_at'].in_time_zone('Australia/Brisbane').strftime('%d/%m/%Y')
        org['id'] = org['legacy_id']
        taxonomy_count.times do |num|
          taxonomy_parent_count.times do |num2|
            if org[:taxonomies].try(:[], num).try(:[], num2).nil?
              org["taxonomy_#{num}_#{num2}"] = nil
            else
              org["taxonomy_#{num}_#{num2}"] = org[:taxonomies][num][num2]
            end
          end
        end

        location_count.times do |num|
          if org[:locations].try(:[], num).nil?
            org["location_#{num}"] = nil
          else
            org["location_#{num}"] = org[:locations][num]['address']
          end
        end

        ci_count.times do |num|
          if org[:country_identifiers].try(:[], num).nil?
            org["ci_#{num}_country_name"] = nil
            org["ci_#{num}_identifier_name"] = nil
            org["ci_#{num}_identifier"] = nil
          else
            org["ci_#{num}_country_name"] = org[:country_identifiers][num][0]
            org["ci_#{num}_identifier_name"] = org[:country_identifiers][num][1]
            org["ci_#{num}_identifier"] = org[:country_identifiers][num][2]
          end
        end

        org
      end
      orgs.each { |org| org.delete(:taxonomies); org.delete(:locations); org.delete(:country_identifiers) }
      array = orgs.map { |org| org.values }
      array.sort_by! { |a| a[0] }
      array.unshift(orgs[0].keys)
      csv_string = CSV.generate do |csv|
        array.each do |arr|
          csv << arr
        end
      end
      context[:data] = csv_string
  end

end
