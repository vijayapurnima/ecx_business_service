class CreateProfile < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles, id: :uuid do |t|
      t.references :resource, index: true, polymorphic: true, type: :uuid
      t.timestamps
    end
  end
end
