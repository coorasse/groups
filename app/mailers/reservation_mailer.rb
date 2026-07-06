class ReservationMailer < ApplicationMailer
  helper GroupsHelper
  helper ReservationsHelper

  BOOKING_INBOX = "prenota@guidaturisticaromagna.it".freeze

  def confirmation(reservation)
    prepare(reservation)
    mail(to: reservation.email, subject: default_i18n_subject(event: @event.title))
  end

  def approval_confirmation(reservation)
    prepare(reservation)
    mail(to: reservation.email, subject: default_i18n_subject(event: @event.title))
  end

  def new_request_notification(reservation)
    prepare(reservation)
    mail(to: BOOKING_INBOX, subject: default_i18n_subject(event: @event.title))
  end

  def new_booking_notification(reservation)
    prepare(reservation)
    mail(to: BOOKING_INBOX, subject: default_i18n_subject(event: @event.title))
  end

  private

  def prepare(reservation)
    @reservation = reservation
    @group = reservation.group
    @event = @group.event
  end
end
