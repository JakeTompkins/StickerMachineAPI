class CreateStickers < ActiveRecord::Migration[5.2]
  def change
    create_table :stickers do |t|
      t.string :title
      t.string :sticker_id
      t.references :user, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
