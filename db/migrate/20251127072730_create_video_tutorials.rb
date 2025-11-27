class CreateVideoTutorials < ActiveRecord::Migration[8.0]
  def change
    create_table :video_tutorials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.float :duration
      t.string :description

      t.timestamps
    end
  end
end
