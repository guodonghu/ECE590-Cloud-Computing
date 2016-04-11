class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :url
      t.string :name
      t.string :userId

      t.timestamps null: false
    end
  end
end
