class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.decimal :adult_price, precision: 8, scale: 2, null: false, default: 0
      t.decimal :kid_price, precision: 8, scale: 2, null: false, default: 0
      t.integer :max_group_size, null: false

      t.timestamps
    end
  end
end
