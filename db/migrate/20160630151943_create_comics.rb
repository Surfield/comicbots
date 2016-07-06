class CreateComics < ActiveRecord::Migration
  def change
    create_table :comics do |t|
      t.string :url, unique: true
      t.string :series
      t.string :issue
      t.string :title
      t.string :writer
      t.string :img_url
      t.string :img64
      t.text :page
      t.timestamps null: false

      #add_index :url, unique: true
    end
  end
end
