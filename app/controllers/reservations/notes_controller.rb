module Reservations
  class NotesController < ApplicationController
    before_action :set_event_and_group
    before_action :set_reservation

    def edit
    end

    def update
      @reservation.update(notes_params)
    end

    private

    def set_event_and_group
      @event = Event.find(params[:event_id])
      @group = @event.groups.find(params[:group_id])
    end

    def set_reservation
      @reservation = @group.reservations.find(params[:reservation_id])
    end

    def notes_params
      params.require(:reservation).permit(:notes)
    end
  end
end
