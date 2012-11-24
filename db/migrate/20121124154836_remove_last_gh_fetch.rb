class RemoveLastGhFetch < ActiveRecord::Migration

  def up
    remove_column :users, :last_gh_fetch
  end

  def down
    change_table :users do |t|
      t.timestamp :last_gh_fetch
    end
  end
end
