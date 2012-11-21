class AddStarredGistSupport < ActiveRecord::Migration

  def up
    change_table :gists do |t|
      t.string :owner_gh_id, :owner_gh_username, :owner_gh_avatar_url
      t.boolean :starred, :owned
    end
  end

  def down
    remove_column :gists, :owner_gh_id
    remove_column :gists, :owner_gh_username
    remove_column :gists, :owner_gh_avatar_url
    remove_column :gists, :starred
    remove_column :gists, :owned
  end
end
