class ReservationsController < ApplicationController
  before_action :set_event_and_group
  before_action :set_reservation, only: %i[show edit update destroy]

  def show
  end

  def new
    @reservation = @group.reservations.build
  end

  def edit
  end

  def create
    @reservation = @group.reservations.build(reservation_params)

    if @reservation.save
      redirect_to event_group_path(@event, @group), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    saved = @reservation.update(reservation_params)

    if inline_request?
      flash[:alert] = @reservation.errors.full_messages.to_sentence unless saved
      redirect_to event_group_path(@event, @group)
    elsif saved
      redirect_to event_group_path(@event, @group), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reservation.destroy
    redirect_to event_group_path(@event, @group), notice: t(".success")
  end

  private

  def set_event_and_group
    @event = Event.find(params[:event_id])
    @group = @event.groups.find(params[:group_id])
  end

  def set_reservation
    @reservation = @group.reservations.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:full_name, :adults_count, :kids_count, :status,
      :owned_adult_tickets, :price_to_pay, :phone, :email, :tax_code, :notes)
  end
end
