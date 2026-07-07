class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @events = Event.order(created_at: :desc)
    @requested_counts = Reservation.requested.joins(:group).group("groups.event_id").count
  end

  def show
    @groups = @event.groups.order(:date, :time)
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: t(".success")
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :short_name, :adult_price, :kid_price,
      :adult_ticket_price, :kid_ticket_price,
      :adult_guided_tour_price, :kid_guided_tour_price,
      :max_group_size, :notify_days_before, :notes, :description, :image, :message_template)
  end
end
