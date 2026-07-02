class AddDataProcessingAuthorizedToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :data_processing_authorized, :boolean, null: false, default: false
  end
end
