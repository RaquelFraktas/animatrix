class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "alive"
      t.integer :kill_count, null: false, default: 0
      t.text :qr_code
      t.integer :killed_user_ids, array: true, default: [], null: false

      t.timestamps
    end

    add_index :users, :status
  end
end
