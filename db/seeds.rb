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

def confirmation_template(meeting_point)
  <<~MESSAGE
    Salve <%= nome_completo %>,
    Le confermo la prenotazione per <%= titolo_evento %> per
    <%= data_ora_gruppo %> (appuntamento 15 min prima #{meeting_point})
    Numero Adulti:<%= numero_adulti %><% if numero_ragazzi > 0 %>, Ragazzi:<%= numero_ragazzi %><% end %>
    Importo: <%= importo_totale %>
    Pagamento sul posto

    Visite guidate a cura di Lisa Rodi
    Cordiali saluti
    Segreteria (Bruno)
    E' attesa una conferma di lettura
  MESSAGE
end

def build_event(title, image: nil, color: nil, **attrs)
  event = Event.find_or_create_by!(title: title) do |e|
    attrs.each { |key, value| e.public_send("#{key}=", value) }
  end

  attach_image(event, image) if image
  attach_placeholder_image(event, color: color) if color
  event
end

[
  { email_address: "admin@example.com", password: "password" },
  { email_address: "manager@example.com", password: "password" }
].each do |attributes|
  SysManager.find_or_create_by!(email_address: attributes[:email_address]) do |sys_manager|
    sys_manager.password = attributes[:password]
  end
end

# Pool of fictional participants reused across groups. Some fields are left blank
# on purpose to exercise the optional email / tax_code paths.
PEOPLE = [
  { full_name: "Mario Rossi",      phone: "+39 333 1234567", email: "mario.rossi@example.com",      tax_code: "RSSMRA80A01H501U" },
  { full_name: "Anna Bianchi",     phone: "+39 340 7654321", email: "anna.bianchi@example.com",     tax_code: "BNCNNA85M41F205X" },
  { full_name: "Giulia Verdi",     phone: "+39 349 1112233", email: "giulia.verdi@example.com",     tax_code: nil },
  { full_name: "Luca Gialli",      phone: "+39 340 9998877", email: nil,                             tax_code: nil },
  { full_name: "Famiglia Neri",    phone: "+39 333 5556677", email: "neri.famiglia@example.com",    tax_code: nil },
  { full_name: "Marco Ferrari",    phone: "+39 335 4433221", email: "marco.ferrari@example.com",    tax_code: "FRRMRC78D12L219K" },
  { full_name: "Sara Esposito",    phone: "+39 348 7766554", email: "sara.esposito@example.com",    tax_code: "SPSSRA90H50F839W" },
  { full_name: "Davide Russo",     phone: "+39 339 2211009", email: "davide.russo@example.com",     tax_code: nil },
  { full_name: "Chiara Romano",    phone: "+39 347 6655443", email: "chiara.romano@example.com",    tax_code: "RMNCHR88T45A662D" },
  { full_name: "Paolo Colombo",    phone: "+39 331 8877665", email: nil,                             tax_code: nil },
  { full_name: "Elena Ricci",      phone: "+39 342 1100998", email: "elena.ricci@example.com",      tax_code: "RCCLNE92C61B354Q" },
  { full_name: "Francesco Marino", phone: "+39 346 5544332", email: "francesco.marino@example.com", tax_code: nil },
  { full_name: "Valentina Greco",  phone: "+39 333 9988776", email: "valentina.greco@example.com",  tax_code: "GRCVNT86P58G273R" },
  { full_name: "Alessandro Conti", phone: "+39 340 3322110", email: "alessandro.conti@example.com", tax_code: nil },
  { full_name: "Martina Bruno",    phone: "+39 349 7766001", email: "martina.bruno@example.com",    tax_code: nil },
  { full_name: "Simone De Luca",   phone: "+39 335 2255889", email: "simone.deluca@example.com",    tax_code: "DLCSMN83L07F205J" },
  { full_name: "Federica Costa",   phone: "+39 348 4411223", email: "federica.costa@example.com",   tax_code: nil },
  { full_name: "Giorgio Fontana",  phone: "+39 331 6677889", email: nil,                             tax_code: nil },
  { full_name: "Laura Moretti",    phone: "+39 342 9900112", email: "laura.moretti@example.com",    tax_code: "MRTLRA91E45H501B" },
  { full_name: "Roberto Barbieri", phone: "+39 346 1212343", email: "roberto.barbieri@example.com", tax_code: nil },
  { full_name: "Silvia Mancini",   phone: "+39 333 3434565", email: "silvia.mancini@example.com",   tax_code: nil },
  { full_name: "Andrea Longo",     phone: "+39 340 5656787", email: "andrea.longo@example.com",     tax_code: "LNGNDR79S20L736T" },
  { full_name: "Beatrice Galli",   phone: "+39 349 7878909", email: "beatrice.galli@example.com",   tax_code: nil },
  { full_name: "Tommaso Rizzo",    phone: "+39 335 9090121", email: nil,                             tax_code: nil }
].freeze

# Different reservation compositions to give the tables varied numbers. When
# price_to_pay is nil the model computes it automatically; a fixed value is used
# to showcase a discrepancy between the paid and the computed amount.
RESERVATION_SHAPES = [
  { adults_count: 2, kids_count: 3, guided_tour_only_adults: 1, status: :confirmed, price_to_pay: nil },
  { adults_count: 1, kids_count: 0, guided_tour_only_adults: 0, status: :paid,      price_to_pay: 20 },
  { adults_count: 2, kids_count: 1, guided_tour_only_adults: 0, status: :requested, price_to_pay: nil },
  { adults_count: 4, kids_count: 2, guided_tour_only_adults: 2, status: :approved,  price_to_pay: nil },
  { adults_count: 3, kids_count: 0, guided_tour_only_adults: 1, status: :confirmed, price_to_pay: nil },
  { adults_count: 2, kids_count: 2, guided_tour_only_adults: 0, status: :requested, price_to_pay: nil },
  { adults_count: 1, kids_count: 1, guided_tour_only_adults: 0, status: :approved,  price_to_pay: nil },
  { adults_count: 5, kids_count: 3, guided_tour_only_adults: 3, status: :paid,      price_to_pay: nil }
].freeze

RESERVATION_NOTES = [
  nil,
  "Allergia alle arachidi.",
  nil,
  "Richiede parcheggio per disabili.",
  nil,
  "Festeggia un compleanno."
].freeze

# Slots spread groups across past and future dates with a mix of statuses. The
# first `count` slots are used for each event, so smaller events still get the
# early open groups while larger ones also get the past / cancelled ones.
GROUP_SLOTS = [
  { offset:   5, status: :open,      notes: nil,                                        net_price: nil, max_group_size: nil, max_overbooking: nil },
  { offset:  12, status: :open,      notes: "Gruppo scolastico, richiesta fattura.",    net_price: nil, max_group_size: nil, max_overbooking: nil },
  { offset: -20, status: :completed, notes: nil,                                        net_price: 180, max_group_size: nil, max_overbooking: nil },
  { offset:  19, status: :open,      notes: "Un partecipante in sedia a rotelle.",      net_price: nil, max_group_size: nil, max_overbooking: nil },
  { offset:  26, status: :closed,    notes: "Gruppo al completo.",                      net_price: nil, max_group_size: 6,   max_overbooking: 0 },
  { offset:  -8, status: :completed, notes: nil,                                        net_price: 95,  max_group_size: nil, max_overbooking: nil },
  { offset:  33, status: :open,      notes: "Comitiva in visita dall'estero.",          net_price: nil, max_group_size: nil, max_overbooking: 4 },
  { offset:  40, status: :cancelled, notes: "Annullato per maltempo.",                  net_price: nil, max_group_size: nil, max_overbooking: nil },
  { offset:  47, status: :open,      notes: nil,                                        net_price: nil, max_group_size: nil, max_overbooking: nil },
  { offset: -33, status: :completed, notes: nil,                                        net_price: 240, max_group_size: nil, max_overbooking: nil }
].freeze

TIME_SLOTS = %w[09:30 10:30 11:00 14:00 15:30 16:00 18:00 20:30].freeze
RESERVATIONS_PER_GROUP = [ 3, 2, 4, 1, 3, 2, 4, 2, 3, 1 ].freeze

def reservation_status(group_status, shape_status, index)
  case group_status
  when :completed then index.even? ? :paid : :confirmed
  when :cancelled then :cancelled
  when :closed    then :confirmed
  else shape_status
  end
end

def seed_reservations(group, count, base, group_status)
  count.times do |offset|
    person = PEOPLE[(base + offset) % PEOPLE.size]
    shape  = RESERVATION_SHAPES[(base + offset) % RESERVATION_SHAPES.size]

    group.reservations.find_or_create_by!(full_name: person[:full_name]) do |reservation|
      reservation.phone = person[:phone]
      reservation.email = person[:email]
      reservation.tax_code = person[:tax_code]
      reservation.adults_count = shape[:adults_count]
      reservation.kids_count = shape[:kids_count]
      reservation.guided_tour_only_adults = shape[:guided_tour_only_adults]
      reservation.status = reservation_status(group_status, shape[:status], offset)
      reservation.price_to_pay = shape[:price_to_pay]
      reservation.notes = RESERVATION_NOTES[(base + offset) % RESERVATION_NOTES.size]
    end
  end
end

def seed_groups(event, count, event_index)
  GROUP_SLOTS.first(count).each_with_index do |slot, index|
    group = event.groups.find_or_create_by!(date: Date.current + slot[:offset], time: TIME_SLOTS[index % TIME_SLOTS.size]) do |g|
      g.status = slot[:status]
      g.notes = slot[:notes]
      g.net_price = slot[:net_price]
      g.max_group_size = slot[:max_group_size]
      g.max_overbooking = slot[:max_overbooking]
    end

    reservations_count = RESERVATIONS_PER_GROUP[index % RESERVATIONS_PER_GROUP.size]
    seed_reservations(group, reservations_count, event_index * 11 + index * 4, slot[:status])
  end
end

EVENTS = [
  {
    title: "Gita al museo",
    image: "museo.png",
    groups: 6,
    attrs: {
      short_name: "Museo Civico",
      adult_price: 25, kid_price: 12,
      adult_ticket_price: 15, kid_ticket_price: 7,
      adult_guided_tour_price: 5, kid_guided_tour_price: 3,
      max_group_size: 8, max_overbooking: 2, notify_days_before: 7,
      notes: "Ritrovo davanti all'ingresso principale 15 minuti prima.",
      description: "Una visita guidata alle collezioni permanenti del museo civico, adatta a famiglie e scolaresche. Durata circa 2 ore.",
      message_template: confirmation_template("all'ingresso principale")
    }
  },
  {
    title: "Laboratorio di ceramica",
    color: [ 196, 106, 92 ],
    groups: 4,
    attrs: {
      adult_price: 40, kid_price: 20,
      adult_ticket_price: 24, kid_ticket_price: 12,
      adult_guided_tour_price: 8, kid_guided_tour_price: 4,
      max_group_size: 6, max_overbooking: 1,
      description: "Un laboratorio pratico di modellazione dell'argilla con un maestro ceramista. Materiali inclusi."
    }
  },
  {
    title: "Visita guidata al cimitero monumentale",
    image: "cimitero.png",
    groups: 5,
    attrs: {
      adult_price: 15, kid_price: 8,
      adult_ticket_price: 10, kid_ticket_price: 5,
      adult_guided_tour_price: 5, kid_guided_tour_price: 3,
      max_group_size: 25, max_overbooking: 5,
      description: "Un percorso serale tra le sculture e le storie dei personaggi illustri sepolti nel cimitero monumentale.",
      message_template: confirmation_template("davanti al cimitero")
    }
  },
  {
    title: "Parco avventura sugli alberi",
    color: [ 76, 148, 84 ],
    groups: 8,
    attrs: {
      short_name: "Parco Avventura",
      adult_price: 30, kid_price: 18,
      adult_ticket_price: 18, kid_ticket_price: 10,
      adult_guided_tour_price: 6, kid_guided_tour_price: 4,
      max_group_size: 12, max_overbooking: 3,
      notes: "Consigliato abbigliamento sportivo e scarpe chiuse.",
      description: "Percorsi acrobatici tra gli alberi con diversi livelli di difficoltà. Attrezzatura di sicurezza fornita sul posto.",
      message_template: confirmation_template("alla biglietteria del parco")
    }
  },
  {
    title: "Degustazione di vini in cantina",
    color: [ 120, 70, 130 ],
    groups: 3,
    attrs: {
      short_name: "Cantina",
      adult_price: 45, kid_price: 15,
      adult_ticket_price: 28, kid_ticket_price: 8,
      adult_guided_tour_price: 10, kid_guided_tour_price: 5,
      max_group_size: 15, max_overbooking: 2,
      description: "Visita alle cantine storiche con degustazione guidata di quattro etichette e prodotti tipici locali."
    }
  },
  {
    title: "Spettacolo teatrale serale",
    color: [ 60, 90, 150 ],
    groups: 10,
    attrs: {
      short_name: "Teatro",
      adult_price: 22, kid_price: 12,
      adult_ticket_price: 14, kid_ticket_price: 8,
      adult_guided_tour_price: 4, kid_guided_tour_price: 2,
      max_group_size: 40, max_overbooking: 8,
      description: "Una serata a teatro con una rappresentazione della compagnia locale. Posti a sedere numerati.",
      message_template: confirmation_template("all'ingresso del teatro")
    }
  }
].freeze

EVENTS.each_with_index do |config, event_index|
  image = config[:image] && Rails.root.join("app/assets/images", config[:image])
  event = build_event(config[:title], image: image, color: config[:color], **config[:attrs])
  seed_groups(event, config[:groups], event_index)
end

# Showcase the "da avvisare" workflow: take the nearest upcoming open group, make
# sure it falls inside its confirmation window, and reset its reservations as if
# they had been booked before the window opened (booking inside the window
# auto-marks them as already notified).
if (demo_group = Group.open.upcoming_candidates.order(:date, :time).first)
  demo_group.update!(notify_days_before: (demo_group.date - Date.current).to_i + 1) unless demo_group.within_notify_window?
  demo_group.reservations.active.update_all(notified: false)
end
