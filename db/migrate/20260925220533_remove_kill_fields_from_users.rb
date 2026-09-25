class RemoveKillFieldsFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :kill_count, :integer
    remove_column :users, :killed_user_ids, :integer
  end
end
