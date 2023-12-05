class RenameProfilesToProfileOrganisationsTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :profiles, :profile_organisations
  end
end
