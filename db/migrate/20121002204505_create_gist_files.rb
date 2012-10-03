class CreateGistFiles < ActiveRecord::Migration
  def change
    create_table :gist_files do |t|
      t.integer :gist_id
      t.string :filename, :raw_url, :language, :file_type
      t.text :content
      t.integer :size_bytes
      t.timestamps
    end

    add_index :gist_files, :gist_id
    add_index :gist_files, :filename
  end
end
