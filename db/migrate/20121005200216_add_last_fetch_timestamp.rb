class AddLastFetchTimestamp < ActiveRecord::Migration
  def up
    add_column :users, :last_gh_fetch, :timestamp
  end

  def down
    remove_column :users, :last_gh_fetch
  end
end
