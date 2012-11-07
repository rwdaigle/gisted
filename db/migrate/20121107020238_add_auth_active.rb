class AddAuthActive < ActiveRecord::Migration

  def up
    add_column :users, :gh_auth_active, :boolean, :default => true
  end

  def down
    remove_column :users, :gh_auth_active
  end
end
