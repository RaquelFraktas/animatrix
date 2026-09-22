class AllowUsersWithoutNames < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :name, true
  end
end