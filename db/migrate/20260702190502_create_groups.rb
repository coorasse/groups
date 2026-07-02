class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :adults_count, null: false, default: 0
      t.integer :kids_count, null: false, default: 0

      t.timestamps
    end
  end
end
