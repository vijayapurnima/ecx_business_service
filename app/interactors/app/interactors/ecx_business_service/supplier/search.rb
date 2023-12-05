# frozen_string_literal: true

class EcxBusinessService::Supplier::Search
  include Interactor

  def call
    set_filters
    context[:results] = []
    if context[:location].present? || context[:range].present? || context[:keyword].present?
      if context[:location].present? && context[:location][:viewport].present?
        locations = if context[:project_id].present?
            EcxBusinessService::Location.where(profile_legacy_id: context[:profile_ids]).select { |l| l.is_in_bounds_or_range?(context[:location], context[:range]) }
          else
            EcxBusinessService::Location.all.select { |l| l.is_in_bounds_or_range?(context[:location], context[:range]) }
          end

        context[:profile_ids] = locations.map { |l| l[:profile_legacy_id] }.uniq

      end

      context[:profiles] = if context[:keyword].present?
                             EcxBusinessService::Profile::Organisation.by_ids_public_profile(context[:profile_ids], context[:by_public_profile]).by_category_ids(context[:category_ids])
                                    .where('lower(trading_name) LIKE :query OR lower(abr_name) LIKE :query OR lower(description) LIKE :query',
                                           { query: "%#{context[:keyword].downcase}%" }).order(created_at: :asc).distinct.page(context[:page]).per(context[:limit_value])
                           else
                             EcxBusinessService::Profile::Organisation.by_ids_public_profile(context[:profile_ids], context[:by_public_profile]).by_category_ids(context[:category_ids])
                                    .order(created_at: :asc).distinct.page(context[:page]).per(context[:limit_value])
                           end
    else
      context[:profiles] = if context[:project_id].present?
                             EcxBusinessService::Profile::Organisation.by_ids_public_profile(context[:profile_ids], context[:by_public_profile]).by_category_ids(context[:category_ids])
                                    .order(created_at: :asc).distinct.page(context[:page]).per(context[:limit_value])
                           else
                             EcxBusinessService::Profile::Organisation.by_public_profile(context[:by_public_profile]).by_category_ids(context[:category_ids])
                                    .order(created_at: :asc).distinct.page(context[:page]).per(context[:limit_value])
                           end
    end

    context[:profiles].each do |profile|
      context[:results].push(profile.attributes.slice(*context[:columns])
      .merge({
               locations: if context[:location].present?
                            locations.select do |l|
                              l[:profile_legacy_id] == profile.legacy_id
                            end
                          else
                            profile.locations
                          end,
              id: profile.legacy_id,
              logo: profile.logo, tags_attributes: profile.tags_attributes.map { |t| t[:title] }
             }))
    end
  end


  def set_filters
      context[:page] = context[:filters].fetch(:page, 1).to_i
      context[:limit_value] = context[:filters].fetch(:limit, 10).to_i
      context[:category_ids] = context[:filters][:category_ids].present? ? context[:filters].fetch(:category_ids, []) : nil
      context[:by_public_profile] = context[:filters].fetch(:by_public_profile, true).to_bool
      context[:project_id] = context[:filters].fetch(:project_id, nil)
      context[:profile_ids] = context[:filters].fetch(:profile_ids, [])
      context[:columns] = context[:columns] ||  %w[logo_id trading_name description public_profile_path]
      context[:columns] << 'id' unless context[:by_public_profile]
      context[:location] = context[:filters][:location]
      context[:range] = context[:filters][:range]
      context[:keyword] = context[:filters][:keyword]
  end
end
