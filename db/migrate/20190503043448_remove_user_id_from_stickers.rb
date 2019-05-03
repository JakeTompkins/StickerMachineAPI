class RemoveUserIdFromStickers < ActiveRecord::Migration[5.2]
  def change
    remove_column :stickers, :user_id
  end
end
