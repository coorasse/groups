module Public
  class BookingsController < BaseController
    before_action :set_reservation

    def show
    end

    private

    def set_reservation
      @reservation = Reservation.find_by!(token: params[:token])
      @group = @reservation.group
      @event = @group.event
    end
  end
end
