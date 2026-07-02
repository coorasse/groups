# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
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
end

museo_group = museo.groups.first_or_create!(date: Date.current + 7, time: "10:30") do |group|
  group.status = :open
  group.notes = "Un bambino con intolleranza alimentare."
end

museo_group.reservations.find_or_create_by!(full_name: "Mario Rossi") do |reservation|
  reservation.adults_count = 2
  reservation.kids_count = 3
  reservation.owned_adult_tickets = 1
  reservation.paid = false
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
  reservation.paid = true
  reservation.status = :approved
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

Event.find_or_create_by!(title: "Laboratorio di ceramica") do |event|
  event.adult_price = 40
  event.kid_price = 20
  event.adult_ticket_price = 24
  event.kid_ticket_price = 12
  event.adult_guided_tour_price = 8
  event.kid_guided_tour_price = 4
  event.max_group_size = 6
  event.description = "Un laboratorio pratico di modellazione dell'argilla con un maestro ceramista. Materiali inclusi."
end
