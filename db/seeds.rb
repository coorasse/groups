# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
require "vips"

# Generates a solid-color placeholder so events have something to show in the booking pages,
# without depending on external image files or network access.
def attach_placeholder_image(event, color:)
  return if event.image.attached?

  image = Vips::Image.black(1200, 675, bands: 3).linear([ 0, 0, 0 ], color)
  event.image.attach(
    io: StringIO.new(image.write_to_buffer(".png")),
    filename: "#{event.title.parameterize}.png",
    content_type: "image/png"
  )
end

def attach_image(event, path)
  return if event.image.attached?

  event.image.attach(
    io: File.open(path),
    filename: File.basename(path),
    content_type: "image/png"
  )
end

[
  { email_address: "admin@example.com", password: "password" },
  { email_address: "manager@example.com", password: "password" }
].each do |attributes|
  SysManager.find_or_create_by!(email_address: attributes[:email_address]) do |sys_manager|
    sys_manager.password = attributes[:password]
  end
end

museo = Event.find_or_create_by!(title: "Gita al museo") do |event|
  event.adult_price = 25
  event.kid_price = 12
  event.adult_ticket_price = 15
  event.kid_ticket_price = 7
  event.adult_guided_tour_price = 5
  event.kid_guided_tour_price = 3
  event.max_group_size = 8
  event.notes = "Ritrovo davanti all'ingresso principale 15 minuti prima."
  event.description = "Una visita guidata alle collezioni permanenti del museo civico, adatta a famiglie e scolaresche. Durata circa 2 ore."
  event.message_template = <<~MESSAGE
    Salve <%= nome_completo %>,
    Le confermo la prenotazione per <%= titolo_evento %> per
    <%= data_ora_gruppo %> (appuntamento 15 min prima all'ingresso principale)
    Numero Adulti:<%= numero_adulti %><% if numero_ragazzi > 0 %>, Ragazzi:<%= numero_ragazzi %><% end %>
    Importo: <%= importo_totale %>
    Pagamento sul posto

    Visite guidate a cura di Lisa Rodi
    Cordiali saluti
    Segreteria (Bruno)
    E' attesa una conferma di lettura
  MESSAGE
end

attach_image(museo, Rails.root.join("app/assets/images/museo.png"))

museo_group = museo.groups.first_or_create!(date: Date.current + 7, time: "10:30") do |group|
  group.status = :open
  group.notes = "Un bambino con intolleranza alimentare."
end

museo_group.reservations.find_or_create_by!(full_name: "Mario Rossi") do |reservation|
  reservation.adults_count = 2
  reservation.kids_count = 3
  reservation.owned_adult_tickets = 1
  reservation.status = :confirmed
  reservation.price_to_pay = nil
  reservation.phone = "+39 333 1234567"
  reservation.email = "mario.rossi@example.com"
  reservation.tax_code = "RSSMRA80A01H501U"
end

museo_group.reservations.find_or_create_by!(full_name: "Anna Bianchi") do |reservation|
  reservation.adults_count = 1
  reservation.kids_count = 0
  reservation.owned_adult_tickets = 0
  reservation.status = :paid
  reservation.price_to_pay = 20
  reservation.phone = "+39 340 7654321"
  reservation.email = "anna.bianchi@example.com"
  reservation.tax_code = "BNCNNA85M41F205X"
end

museo_group.reservations.find_or_create_by!(full_name: "Giulia Verdi") do |reservation|
  reservation.adults_count = 2
  reservation.kids_count = 1
  reservation.owned_adult_tickets = 0
  reservation.status = :requested
  reservation.price_to_pay = nil
  reservation.phone = "+39 349 1112233"
  reservation.email = "giulia.verdi@example.com"
end

ceramica = Event.find_or_create_by!(title: "Laboratorio di ceramica") do |event|
  event.adult_price = 40
  event.kid_price = 20
  event.adult_ticket_price = 24
  event.kid_ticket_price = 12
  event.adult_guided_tour_price = 8
  event.kid_guided_tour_price = 4
  event.max_group_size = 6
  event.description = "Un laboratorio pratico di modellazione dell'argilla con un maestro ceramista. Materiali inclusi."
end
attach_placeholder_image(ceramica, color: [ 196, 106, 92 ])

cimitero = Event.find_or_create_by!(title: "Visita guidata al cimitero monumentale") do |event|
  event.adult_price = 15
  event.kid_price = 8
  event.adult_ticket_price = 10
  event.kid_ticket_price = 5
  event.adult_guided_tour_price = 5
  event.kid_guided_tour_price = 3
  event.max_group_size = 25
  event.description = "Un percorso serale tra le sculture e le storie dei personaggi illustri sepolti nel cimitero monumentale."
  event.message_template = <<~MESSAGE
    Salve <%= nome_completo %>,
    Le confermo la prenotazione per <%= titolo_evento %> per
    <%= data_ora_gruppo %> (appuntamento 15 min prima davanti al cimitero)
    Numero Adulti:<%= numero_adulti %><% if numero_ragazzi > 0 %>, Ragazzi:<%= numero_ragazzi %><% end %>
    Importo: <%= importo_totale %>
    Pagamento sul posto

    Visite guidate a cura di Lisa Rodi
    Cordiali saluti
    Segreteria (Bruno)
    E' attesa una conferma di lettura
  MESSAGE
end

attach_image(cimitero, Rails.root.join("app/assets/images/cimitero.png"))

cimitero_group = cimitero.groups.first_or_create!(date: Date.current + 3, time: "20:30") do |group|
  group.status = :open
end

cimitero_group.reservations.find_or_create_by!(full_name: "Famiglia Neri") do |reservation|
  reservation.adults_count = 2
  reservation.kids_count = 1
  reservation.status = :confirmed
  reservation.phone = "+39 333 5556677"
  reservation.notes = "Un partecipante in sedia a rotelle."
end

cimitero_group.reservations.find_or_create_by!(full_name: "Luca Gialli") do |reservation|
  reservation.adults_count = 2
  reservation.kids_count = 0
  reservation.status = :requested
  reservation.phone = "+39 340 9998877"
end
