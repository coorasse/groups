class AddTicketPricesToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :adult_ticket_price, :decimal, precision: 8, scale: 2, null: false, default: 0
    add_column :events, :kid_ticket_price, :decimal, precision: 8, scale: 2, null: false, default: 0
  end
end
