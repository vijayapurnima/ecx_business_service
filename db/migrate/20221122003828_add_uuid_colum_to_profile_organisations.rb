class AddUuidColumToProfileOrganisations < ActiveRecord::Migration[5.2]
  def change
    rename_column :profile_organisations, :id, :legacy_id
    execute 'ALTER TABLE profile_organisations drop constraint profile_organisations_pkey;'
    add_index :profile_organisations, :legacy_id, unique: true

    add_column :profile_organisations, :id, :uuid, default: 'gen_random_uuid()', null: false
    execute'ALTER TABLE profile_organisations ADD PRIMARY KEY (id);'
    
    execute("UPDATE profile_organisations p SET id = '#{SecureRandom.uuid}' where id is NOT NULL;")
  end
end
