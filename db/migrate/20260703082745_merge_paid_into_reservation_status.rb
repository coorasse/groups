class MergePaidIntoReservationStatus < ActiveRecord::Migration[8.1]
  # status enum: requested: 0, approved: 1, confirmed: 2, cancelled: 3, paid: 4
  PAID = 4
  CONFIRMED = 2

  def up
    execute "UPDATE reservations SET status = #{PAID} WHERE paid = #{connection.quoted_true}"
    remove_column :reservations, :paid
  end

  def down
    add_column :reservations, :paid, :boolean, null: false, default: false
    execute "UPDATE reservations SET paid = #{connection.quoted_true}, status = #{CONFIRMED} WHERE status = #{PAID}"
  end
end
