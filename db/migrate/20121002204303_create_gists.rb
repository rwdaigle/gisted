class CreateGists < ActiveRecord::Migration
  def change
    create_table :gists do |t|
      t.string :gh_id, :unique => true
      t.integer :user_id
      t.text :description
      t.string :url, :git_pull_url, :git_push_url
      t.boolean :public
      t.integer :comment_count
      t.timestamp :gh_created_at
      t.timestamp :gh_updated_at
      t.timestamps
    end

    add_index :gists, :gh_id
    add_index :gists, :user_id
  end
end