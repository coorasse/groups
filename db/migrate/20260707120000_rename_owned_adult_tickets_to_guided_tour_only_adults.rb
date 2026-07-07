class RenameOwnedAdultTicketsToGuidedTourOnlyAdults < ActiveRecord::Migration[8.1]
  def change
    rename_column :reservations, :owned_adult_tickets, :guided_tour_only_adults
  end
end
