class AddExcerptFieldsToPost < ActiveRecord::Migration
	def self.up
    add_column :posts, :excerpt, :text
    add_column :posts, :excerpt_html, :text
  end

  def self.down
    remove_column :posts, :excerpt_html
    remove_column :posts, :excerpt
  end
end
