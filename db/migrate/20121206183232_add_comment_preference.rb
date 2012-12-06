class AddCommentPreference < ActiveRecord::Migration

  def up
    change_table :users do |t|
      t.boolean :notify_comments, :default => false
    end
  end

  def down
    remove_column :users, :notify_comments
  end
end
