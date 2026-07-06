module Public
  class ReservationsController < ApplicationController
    allow_unauthenticated_access
    layout "public"

    # La form pubblica è cookieless: non scrive alcun cookie, così non serve il
    # cookie banner. Saltiamo la sessione (nessun cookie viene emesso) e, dato che
    # senza sessione la CSRF protection basata su token non è utilizzabile, la
    # sostituiamo con la verifica dell'header `Sec-Fetch-Site`: accettiamo solo
    # richieste same-origin / same-site.
    #
    # Questo replica ciò che Rails 8.2 farà nativamente con
    # `protect_from_forgery using: :header_only` (rails/rails#56350).
    # TODO(rails 8.2): rimuovere `skip_session` + `verify_same_site_request` e
    # sostituirli con `protect_from_forgery using: :header_only`.
    skip_forgery_protection
    before_action :skip_session
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
      @reservation = @group.reservations.build
    end

    def create
      @reservation = @group.reservations.build(reservation_params)
      @reservation.status = :requested

      if @reservation.save(context: :public_booking)
        ReservationMailer.confirmation(@reservation).deliver_later if @reservation.email.present?
        redirect_to public_confirmation_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def confirmation
    end

    private

    def skip_session
      request.session_options[:skip] = true
    end

    ALLOWED_FETCH_SITES = %w[same-origin same-site].freeze

    def verify_same_site_request
      return if ALLOWED_FETCH_SITES.include?(request.headers["Sec-Fetch-Site"])

      head :forbidden
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
