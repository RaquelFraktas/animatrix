class CreateKills < ActiveRecord::Migration[8.1]
  def change
    create_table :kills do |t|
      t.references :killer, null: false, foreign_key: { to_table: :users }
      t.references :victim, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
