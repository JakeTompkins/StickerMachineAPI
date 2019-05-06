class DropUsers < ActiveRecord::Migration[5.2]
  def up
    drop_table :users
  end

  def down
  end
end
