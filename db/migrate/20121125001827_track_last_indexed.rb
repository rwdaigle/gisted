class TrackLastIndexed < ActiveRecord::Migration

  def up
    change_table :users do |t|
      t.timestamp :last_indexed_at
    end
  end

  def down
    remove_column :users, :last_indexed_at
  end
end
