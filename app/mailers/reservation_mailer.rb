class ReservationMailer < ApplicationMailer
  helper GroupsHelper
  helper ReservationsHelper

  def confirmation(reservation)
    @reservation = reservation
    @group = reservation.group
    @event = @group.event

    mail(to: reservation.email, subject: default_i18n_subject(event: @event.title))
  end

  def approval_confirmation(reservation)
    @reservation = reservation
    @group = reservation.group
    @event = @group.event

    mail(to: reservation.email, subject: default_i18n_subject(event: @event.title))
  end

  def new_request_notification(reservation)
    @reservation = reservation
    @group = reservation.group
    @event = @group.event

    mail(to: "prenota@guidaturisticaromagna.it", subject: default_i18n_subject(event: @event.title))
  end
end
