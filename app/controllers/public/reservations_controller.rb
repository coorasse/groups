module Public
  class ReservationsController < BaseController
    before_action :verify_same_site_request, only: :create
    before_action :set_event, only: %i[new create]
    before_action :set_bookable_groups, only: %i[new create]

    def index
      @events_with_groups = Group.upcoming_candidates
                                 .includes(:event, :reservations)
                                 .order(:date, :time)
                                 .select(&:bookable?)
                                 .group_by(&:event)
    end

    def new
      @reservation = Reservation.new(group: @bookable_groups.first, adults_count: nil, kids_count: nil)
    end

    def create
      @reservation = Reservation.new(reservation_params)
      @group = @bookable_groups.find { |group| group.id == @reservation.group_id }
      @reservation.group = @group

      if @group.nil?
        @reservation.errors.add(:base, :group_required)
        render :new, status: :unprocessable_entity
      elsif @group.fits_within_overbooking?(@reservation.people_count)
        finalize(:confirmed)
      elsif force_request?
        finalize(:requested)
      else
        @reservation.errors.add(:base, :not_enough_seats)
        render :new, status: :unprocessable_entity
      end
    end

    private

    # A request that fits within the plain seats plus the overbooking allowance
    # is confirmed straight away. Anything beyond it is kept as a request, when the
    # person insists on their date, for the operator to handle.
    def finalize(status)
      @reservation.status = status

      if @reservation.save(context: :public_booking)
        notify_about(@reservation)
        redirect_to booking_path(@reservation.token)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def force_request?
      ActiveModel::Type::Boolean.new.cast(params[:force_request])
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

    def set_event
      @event = Event.find(params[:event_id])
    end

    def set_bookable_groups
      @bookable_groups = @event.groups
                               .upcoming_candidates
                               .includes(:reservations)
                               .select(&:bookable?)
                               .sort_by { |group| [ group.date, group.time ] }
      # Niente flash: dipenderebbe dalla sessione (che qui è disabilitata).
      redirect_to public_root_path(unavailable: true) if @bookable_groups.empty?
    end

    def reservation_params
      params.require(:reservation).permit(:group_id, :full_name, :adults_count, :kids_count,
        :phone, :email, :notes, :data_processing_authorized)
    end
  end
end
