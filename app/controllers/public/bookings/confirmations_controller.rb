module Public
  module Bookings
    class ConfirmationsController < BaseController
      before_action :verify_same_site_request
      before_action :set_reservation

      def update
        # Solo le prenotazioni approvate possono essere confermate dall'utente.
        # Su ogni altro stato è un no-op idempotente: la pagina mostrerà lo stato
        # corrente. Questo evita anche che un preview bot (che fa solo GET) possa
        # confermare: la conferma avviene esclusivamente via questa PATCH same-site.
        @reservation.confirmed! if @reservation.approved?
        redirect_to booking_path(@reservation.token)
      end

      private

      def set_reservation
        @reservation = Reservation.find_by!(token: params[:booking_token])
      end
    end
  end
end
