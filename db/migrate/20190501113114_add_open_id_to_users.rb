class AddOpenIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :open_id, :string
    add_index :users, :open_id, unique: true
  end
end
