FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "Evento #{n}" }
    adult_price { 20.00 }
    kid_price { 10.00 }
    adult_ticket_price { 12.00 }
    kid_ticket_price { 6.00 }
    adult_guided_tour_price { 5.00 }
    kid_guided_tour_price { 3.00 }
    max_group_size { 10 }
  end
end
