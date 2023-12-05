# frozen_string_literal: true

class InitSchema < ActiveRecord::Migration[7.0]

  def up
    execute(File.read(File.join(EcxBusinessService::Engine.root,"db/init_structure.sql")))
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not able to be reverted."
  end
end

