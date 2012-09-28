class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :gh_username
      t.string :gh_oauth_token, :unique => true
      t.string :gh_avatar_url
      t.string :gh_url
      t.timestamps
    end
  end
end
