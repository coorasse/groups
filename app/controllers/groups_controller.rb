class GroupsController < ApplicationController
  before_action :set_event, except: :index
  before_action :set_group, only: %i[show edit update destroy]

  def index
    @groups = Group.open.includes(:event).order(:date, :time)
    @requested_counts = Reservation.requested.joins(:group)
                                   .where(groups: { status: Group.statuses[:open] })
                                   .group("groups.id").count
    @requested_reservations = Reservation.requested.includes(group: :event)
                                          .references(:group)
                                          .order(Arel.sql("groups.date, groups.time"))
    @to_notify_counts = Reservation.active.where(notified: false, group: @groups)
                                   .group(:group_id).count
  end

  def show
    @reservations = @group.reservations.order(:created_at, :id)
  end

  def new
    @group = @event.groups.build
  end

  def edit
  end

  def create
    @group = @event.groups.build(group_params)

    if @group.save
      redirect_to @event, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    saved = @group.update(group_params)

    if inline_request?
      flash[:alert] = @group.errors.full_messages.to_sentence unless saved
      redirect_to event_group_path(@event, @group)
    elsif saved
      redirect_to event_group_path(@event, @group), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to @event, notice: t(".success")
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_group
    @group = @event.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:date, :time, :status, :notes, :net_price,
      :max_group_size, :max_overbooking, :notify_days_before)
  end
end
