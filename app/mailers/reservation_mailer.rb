class ReservationMailer < ApplicationMailer
  helper GroupsHelper

  def confirmation(reservation)
    @reservation = reservation
    @group = reservation.group
    @event = @group.event

    mail(to: reservation.email, subject: default_i18n_subject(event: @event.title))
  end
end
