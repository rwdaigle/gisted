class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :gh_id, :unique => true
      t.string :gh_username, :gh_email, :gh_name
      t.string :gh_oauth_token, :unique => true
      t.string :gh_avatar_url, :gh_url
      t.timestamps
    end

    add_index :users, :gh_id
  end
end
