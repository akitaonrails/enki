class CreateUpload < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.timestamps
    end
  end
  
  def self.down
    drop_table :uploads
  end
end
