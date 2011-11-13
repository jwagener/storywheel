class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :slug
      t.string :title
      t.string :sc_username
      t.string :sc_permalink
      t.integer :sc_user_id
      t.integer :story_track_id
      t.integer :background_track_id
      t.text :images
      t.text :data

      t.timestamps
    end
  end
end
