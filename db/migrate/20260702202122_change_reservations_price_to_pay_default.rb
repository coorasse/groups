class ChangeReservationsPriceToPayDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :reservations, :price_to_pay, from: 0, to: nil
  end
end
