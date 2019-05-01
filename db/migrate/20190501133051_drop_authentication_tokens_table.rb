class DropAuthenticationTokensTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :authentication_tokens
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
