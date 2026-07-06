module Public
  class ReservationsController < BaseController
    before_action :verify_same_site_request, only: :create
    before_action :set_bookable_group, only: %i[new create]

    def index
      @events_with_groups = Group.upcoming_candidates
                                 .includes(:event, :reservations)
                                 .order(:date, :time)
                                 .select(&:bookable?)
                                 .group_by(&:event)
    end

    def new
      @reservation = @group.reservations.build(adults_count: nil, kids_count: nil)
    end

    def create
      @reservation = @group.reservations.build(reservation_params)
      @reservation.status = auto_confirmable? ? :confirmed : :requested

      if @reservation.save(context: :public_booking)
        notify_about(@reservation)
        redirect_to booking_path(@reservation.token)
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    # A request that fits within the plain seats is confirmed straight away;
    # anything that would spill into the overbooking allowance stays a request.
    def auto_confirmable?
      @group.fits_available_seats?(@reservation.people_count)
    end

    def notify_about(reservation)
      if reservation.confirmed?
        ReservationMailer.approval_confirmation(reservation).deliver_later if reservation.email.present?
        ReservationMailer.new_booking_notification(reservation).deliver_later
      else
        ReservationMailer.confirmation(reservation).deliver_later if reservation.email.present?
        ReservationMailer.new_request_notification(reservation).deliver_later
      end
    end

    def set_bookable_group
      @group = Group.find(params[:group_id])
      @event = @group.event
      # Niente flash: dipenderebbe dalla sessione (che qui è disabilitata).
      redirect_to public_root_path(unavailable: true) unless @group.bookable?
    end

    def reservation_params
      params.require(:reservation).permit(:full_name, :adults_count, :kids_count,
        :phone, :email, :notes, :data_processing_authorized)
    end
  end
end
