class RemoveForeignKeyAndUpdateProfileIdColumn < ActiveRecord::Migration[5.2]
  def change
    ## remove foriegn_keys
    remove_foreign_key :case_studies, column: :profile_id
    remove_foreign_key :certifications, column: :profile_id
    remove_foreign_key :country_identifiers, column: :profile_id
    remove_foreign_key :insurance_coverages, column: :profile_id
    # remove_foreign_key :locations, column: :profile_id
    remove_foreign_key :product_services, column: :profile_id
    remove_foreign_key :profile_billings, column: :profile_id
    remove_foreign_key :profile_groups, column: :profile_id
    remove_foreign_key :tags, column: :profile_id

    ##  RENAME column name in above tables from profile_id to profile_organisation_legacy_id
    rename_column :case_studies, :profile_id, :profile_legacy_id
    rename_column :certifications, :profile_id, :profile_legacy_id
    rename_column :country_identifiers, :profile_id, :profile_legacy_id
    rename_column :insurance_coverages, :profile_id, :profile_legacy_id
    rename_column :locations, :profile_id, :profile_legacy_id
    rename_column :product_services, :profile_id, :profile_legacy_id
    rename_column :profile_billings, :profile_id, :profile_legacy_id
    rename_column :profile_groups, :profile_id, :profile_legacy_id
    rename_column :tags, :profile_id, :profile_legacy_id
    ## change all models linking to profile-- DONE in model files
  end
end
