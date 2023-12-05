class AddLegacyIdForeignKeyToProfileReferences < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :case_studies, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :certifications, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :country_identifiers, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :insurance_coverages, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :product_services, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :profile_billings, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :profile_groups, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :tags, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
    add_foreign_key :locations, :profile_organisations, column: :profile_legacy_id, primary_key: "legacy_id"
     
  end
end
