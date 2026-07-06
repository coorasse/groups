class AddTokenToReservations < ActiveRecord::Migration[8.1]
  def up
    add_column :reservations, :token, :string
    Reservation.reset_column_information
    Reservation.where(token: nil).find_each { |reservation| reservation.update_columns(token: SecureRandom.base58(24)) }
    change_column_null :reservations, :token, false
    add_index :reservations, :token, unique: true
  end

  def down
    remove_column :reservations, :token
  end
end
