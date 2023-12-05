require 'base64'
require 'tempfile'

class EcxBusinessService::Profile::Organisation < EcxBusinessService::ApplicationRecord
  include AASM

  has_many :profile_groups, class_name: 'EcxBusinessService::Profile::Group', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :groups, through: :profile_groups
  has_many :locations, class_name: 'EcxBusinessService::Location', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :taxonomy_links, -> { includes :taxonomy }, as: :owner, foreign_key: :owner_id, primary_key: :legacy_id
  has_many :taxonomies, through: :taxonomy_links
  has_many :country_identifiers, class_name: 'EcxBusinessService::CountryIdentifier', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :countries, through: :country_identifiers
  has_many :insurance_coverages, class_name: 'EcxBusinessService::InsuranceCoverage', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :certifications, class_name: 'EcxBusinessService::Certification', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :tags,  class_name: 'EcxBusinessService::Tag', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :case_studies, class_name: 'EcxBusinessService::CaseStudy', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :categories, through: :tags
  has_one  :profile_billing, class_name: 'EcxBusinessService::Profile::Billing', foreign_key: :profile_legacy_id, primary_key: :legacy_id
  has_many :product_services, class_name: 'EcxBusinessService::ProductService', foreign_key: :profile_legacy_id, primary_key: :legacy_id

  attribute :registration_contact, :string, default: 'Business Administrator'

  accepts_nested_attributes_for :locations, allow_destroy: true
  accepts_nested_attributes_for :country_identifiers, allow_destroy: true
  accepts_nested_attributes_for :tags, allow_destroy: true
  validates :public_profile_path, uniqueness: true, allow_nil: true

  EDIT_PARAMS               = %w[trading_name registration_contact description year_founded size website ownership_type atsi_owned atsi_operated logo_id
                                 capability_statement_id disability_enterprise public_profile public_profile_path]
  CREATE_PARAMS             = EDIT_PARAMS + %w[abn abr_name trading_name]
  PROFILE_COMPLETION_FIELDS = %w[trading_name size description year_founded ownership_type website]

  default_scope do
    includes(:locations, :tags, certifications: :certificate_type, insurance_coverages: :insurance, country_identifiers: :country, taxonomy_links: :taxonomy)
  end
  scope :only_active, -> { where(status: [nil, 'active']) }
  scope :load_taxonomies, -> { eager_load(:taxonomy_links) }
  scope :with_identifiers, ->  { joins('LEFT OUTER JOIN country_identifiers AS c2 on c2.profile_legacy_id=profile_organisations.legacy_id') }
  scope :by_groups_and_taxonomies, ->(group, taxonomies) { by_org_groups(group).by_taxonomies(taxonomies) }
  scope :by_taxonomies, ->(taxonomies) { joins(taxonomy_links: :taxonomy).where('taxonomies.id': taxonomies) }
  scope :by_org_groups, lambda { |group|
                          joins(profile_groups: { group_level: :group }).where('profile_groups.group_id': group['group_id'], 'profile_groups.group_level_id': group['group_levels'])
                        }
  scope :by_country, ->(country_id) { joins("LEFT OUTER JOIN country_identifiers AS c2 on c2.country_id=#{country_id}") }
  scope :public_profile_enabled, -> { where(public_profile: true) }
  scope :by_ids_public_profile, ->(profile_ids, by_public_profile) { where(legacy_id: profile_ids, public_profile: by_public_profile ? true : [true, false]) }
  scope :by_public_profile, ->(by_public_profile) { where(public_profile: by_public_profile ? true : [true, false]) }
  scope :by_category_ids, ->(category_ids) { category_ids.present? ? includes(:categories).where({ categories: { id: category_ids } }) : includes(:categories) }

  after_create :clear_cache
  after_save :clear_cache
  before_create :set_need_update
  before_save :check_completion

  aasm whiny_transitions: :false, column: 'status' do
    state :active, initial: :true
    state :inactive

    event :activate do
      transitions from: :inactive, to: :active
    end
    event :deactivate do
      transitions from: :active, to: :inactive
    end
  end

  def inactive?
    status == 'inactive'
  end

  def business_name
    bus_name || abr_name
  end

  def profile_complete
    percentage_completed >= 100
  end

  def percentage_completed
    count           = 0
    included_fields = attributes.select { |p, _v| PROFILE_COMPLETION_FIELDS.include? p }
    total_fields    = included_fields.count + 2 # Add 4 to the count for Location and Capability Statement, Market Alignment

    count += included_fields.count { |_k, v| !(v.nil? || v.blank?) }
    count += 1 if locations_complete
    count += 1 if !market_alignment.nil? && market_alignment_present

    count == 0 ? 0 : (count * 100 / total_fields).round
  end

  def business_details_complete
    (attributes.select { |p, _v| PROFILE_COMPLETION_FIELDS.include? p }.count { |_k, v| !(v.nil? || v.blank?) } == PROFILE_COMPLETION_FIELDS.length) &&
      !market_alignment.nil? && market_alignment_present
  end

  def locations_complete
    locations.length > 0 && !(locations.any? { |location| location.address.blank? || location.location_type.blank? })
  end

  def capability_statement_uploaded
    !capability_statement_id.blank?
  end

  def percentage_show
    percentage_completed.to_s + '%'
  end

  def anzsic_values
    taxonomy_links.map { |tl| tl.taxonomy }.select { |tax| tax.group_name == 'ANZSIC' }.first
  end

  def anzsic_classification
    anzsic_values.ancestor_keys unless anzsic_values.nil?
  end

  def capability_statement
    unless capability_statement_id.nil?
      result = GetAttachment.call(id: capability_statement_id, which: 'details', disposition: nil)

      result.attachment
    end
  end

  def logo
    if logo_id.nil?
      to_base64(EcxBusinessService::Profile::Organisation.logo_placeholder_file)
    else
      result = GetAttachment.call(id: logo_id, which: 'file', disposition: nil, with_resize: false)
      return nil unless result.success?
      tempfile = Tempfile.new(SecureRandom.uuid)
      tempfile.binmode
      begin
        tempfile.write(result.attachment)
        tempfile.rewind
        to_base64(tempfile.path)
      ensure
        tempfile.close
        tempfile.unlink
      end
    end
  end

  def to_base64(path)
    'data:image/png;base64,' + Base64.encode64(File.read(path)) if File.exist?(path)
  end

  def validate_data
    errors[:base] << 'Trading Name is required' if !new_record? && trading_name.blank?
    errors[:base] << 'Business Description is required' if !new_record? && description.blank?
    errors[:base] << 'Business Year Founded is required' if !new_record? && year_founded.blank?
    errors[:base] << 'Company Size is required' if !new_record? && size.blank?
    errors[:base] << 'Ownership type is required' if !new_record? && ownership_type.blank?
    errors[:base] << 'Website URL is required' if !new_record? && website.blank?
    errors[:base] << 'Market Alignment total must not be greater than 100' unless new_record? || market_alignment_present

    errors[:base].length > 0 ? (raise ActiveRecord::RecordInvalid, self) : true
  end

  def completion_details
    [{ key: 'profile', description: 'Business Details', value: business_details_complete },
     { key: 'locations', description: 'Office Locations', value: locations_complete }]
  end

  def alerts_list
    [
      { key: 'location', value: !locations_complete, description: 'No Business Location' },
      { key: 'logo', value: !logo_id.present?, description: 'No Business Logo' },
      { key: 'industry_classification', value: !anzsic_classification.present?, description: 'No Industry Classification' }
    ]
  end

  def notifications_list
    [
      { key: 'business_capabilties', value: !tags_attributes.present?, description: 'No Business Capabilities' },
      { key: 'product_services', value: !product_services.present?, description: 'No Products & Services' },
      { key: 'case_studies', value: !case_studies.present?, description: 'No Case Studies' },
      { key: 'more_business_capabilities', value: tags_attributes.length > 0 && tags_attributes.length < 3, description: 'Add More Capabilities' },
      { key: 'more_case_studies', value: case_studies.length > 0 && case_studies.length < 3, description: 'Add More Case Studies' },
      { key: 'enable_public_profile', value: !public_profile.present?, description: 'Enable Public Profile' }
    ]
  end

  def market_alignment_present
    unless market_alignment.nil?
      market_alignment                                                 = JSON.parse(self.market_alignment)
      percent                                                          = 0
      market_alignment['revenue_source1'].blank? ? percent : (percent += market_alignment['revenue_source1_perc'].to_f)
      market_alignment['revenue_source2'].blank? ? percent : (percent += market_alignment['revenue_source2_perc'].to_f)
      market_alignment['revenue_source3'].blank? ? percent : (percent += market_alignment['revenue_source3_perc'].to_f)

      percent >= 1 && percent <= 100.to_f
    end
  end

  def profile_market_alignment
    JSON.parse(market_alignment, symbolize_names: true) unless market_alignment.nil?
  end

  def tags_attributes
    Rails.cache.fetch("business/profile_tags/#{legacy_id}") do
      tags = self.tags
      tags.map do |t|
        t.slice(:id, :profile_legacy_id, :category_id).merge({ title: t.category.title })
      end
    end
  end

  def clear_cache
    Rails.cache.delete('business/profile/organisations')
    Rails.cache.delete('business/profile/organisations/admin')
    Rails.cache.delete("business/profile/organisations/set_profile/#{legacy_id}")
    Rails.cache.delete("business/profile/organisations/profile_tags/#{legacy_id}")
    Rails.cache.delete_matched("business/profile/organisations/get_profile/#{legacy_id}/redactor-")
    Rails.cache.delete_matched('business/profile/organisations/byIds*')

    redactor_access_levels = %w[me buyer edo admin public]
    redactor_access_levels.each { |level| Rails.cache.delete("business/profile/organisations/get_profile/#{legacy_id}/redactor-#{level}") }
  end

  def check_completion
    self.need_update = false if business_details_complete
  end

  def search_data
    {
      name:            name.downcase,
      description:     description.downcase,
      category_titles: tags_attributes.pluck(:title)
    }
  end

  def self.logo_placeholder_file
    File.join(Rails.root, 'engines/ecx_business_service/app/assets/images/ecx_business_service/organisation_logo_placeholder.jpg')
  end

  private
  # def modify_sequence
  #   sequence_id = ApplicationRecord.connection.select_value("SELECT setval('profiles_id_seq', #{id}, TRUE)") unless id.nil?
  # end

  def set_need_update
    self.need_update = false # setting this to false for new business as we do not want to show a prompt for a new business
  end
end
