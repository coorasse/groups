class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :group, null: false, foreign_key: true
      t.string :full_name, null: false
      t.integer :adults_count, null: false, default: 0
      t.integer :kids_count, null: false, default: 0
      t.boolean :paid, null: false, default: false
      t.integer :owned_adult_tickets, null: false, default: 0
      t.decimal :price_to_pay, precision: 8, scale: 2, null: false, default: 0
      t.string :phone
      t.string :email
      t.string :tax_code
      t.text :notes

      t.timestamps
    end
  end
end
