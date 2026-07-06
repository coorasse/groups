module Reservations
  class ConfirmationEmailsController < ApplicationController
    before_action :set_event_and_group
    before_action :set_reservation

    def create
      if @reservation.email.blank?
        redirect_to event_group_path(@event, @group), alert: t(".no_email")
        return
      end

      ReservationMailer.approval_confirmation(@reservation).deliver_later
      redirect_to event_group_path(@event, @group), notice: t(".success")
    end

    private

    def set_event_and_group
      @event = Event.find(params[:event_id])
      @group = @event.groups.find(params[:group_id])
    end

    def set_reservation
      @reservation = @group.reservations.find(params[:reservation_id])
    end
  end
end
