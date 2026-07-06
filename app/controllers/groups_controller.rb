class GroupsController < ApplicationController
  before_action :set_event
  before_action :set_group, only: %i[show edit update destroy]

  def show
    @reservations = @group.reservations.order(:full_name)
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
    params.require(:group).permit(:date, :time, :status, :notes, :net_price)
  end
end
