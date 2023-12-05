# frozen_string_literal: true

class EcxBusinessService::Location < EcxBusinessService::ApplicationRecord
  belongs_to :profile, class_name: 'EcxBusinessService::Profile::Organisation', foreign_key: :profile_legacy_id, primary_key: :legacy_id

  validates :location_type, inclusion: { in: %w[Head Branch] }

  UPDATE_FIELDS  = %i[location_type address].freeze
  EARTH_RADIUS   = 6371 # Earth radius in kilometers
  RADIAN_PER_DEG = Math::PI / 180 # PI / 180

  def self.by_profile_ids(profile_ids)
    profile_ids.present? ? where(profile_legacy_id: profile_ids) : all
  end

  def location_present?
    !(address.blank? || location_type.blank?)
  end

  # Methods to calculate lat lng are in given bounds are inspired from
  # https://stackoverflow.com/questions/46805795/check-if-coordinate-belongs-to-square-given-ne-and-sw-corrds-of-region
  def is_in_bounds?(viewport)
    viewport[:southwest][:lat].try(:to_f) < latitude &&
      viewport[:northeast][:lat].try(:to_f) > latitude &&
      normalizeDegrees(longitude - viewport[:southwest][:lng].try(:to_f)) < normalizeDegrees(viewport[:northeast][:lng].try(:to_f) - viewport[:southwest][:lng].try(:to_f))
  end

  def normalizeDegrees(value)
    value < 0 ? (360 + value % 360) : (value % 360)
  end

  def distance2pointsInMeters(loc1, loc2)
    rad_per_deg = Math::PI / 180 # PI / 180
    rkm         = 6371          # Earth radius in kilometers
    rm          = rkm * 1000    # Radius in meters

    dlat_rad    = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
    dlon_rad    = (loc2[1] - loc1[1]) * rad_per_deg

    lat1_rad    = loc1.map { |i| i * rad_per_deg }.first
    lat2_rad    = loc2.map { |i| i * rad_per_deg }.first

    a           = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c           = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rm * c # Delta in meters
  end

  # https://gist.github.com/zulhfreelancer/15071f8678bcb38442648eda8dfcf387
  def distance(from_location)
    dlat_rad = (latitude - from_location[:lat].try(:to_f)) * RADIAN_PER_DEG # Delta, converted to rad
    dlon_rad = (longitude - from_location[:lng].try(:to_f)) * RADIAN_PER_DEG

    lat1_rad = from_location[:lat].try(:to_f) * RADIAN_PER_DEG
    lat2_rad = latitude * RADIAN_PER_DEG

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    EARTH_RADIUS * c # Delta in kms
  end

  # location must be of format {lat:,lng:,viewport:{southwest: {lat:, lng:}, northeast: {lat:,lng:}}}
  def is_in_bounds_or_range?(location, range = nil)
    is_in_bounds?(location[:viewport]) || (in_range?(location, range) if range.present?)
  end

  # location must be of format {lat:,lng:,viewport:{southwest: {lat:, lng:}, northeast: {lat:,lng:}}}
  def in_range?(location, range)
    distance(location).round(2) <= range.try(:to_f)
  end
end
