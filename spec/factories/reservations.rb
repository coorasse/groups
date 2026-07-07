FactoryBot.define do
  factory :reservation do
    group
    sequence(:full_name) { |n| "Prenotante #{n}" }
    adults_count { 2 }
    kids_count { 1 }
    guided_tour_only_adults { 0 }
    price_to_pay { nil }
    phone { "+39 333 1234567" }
    email { "prenotante@example.com" }
    tax_code { "RSSMRA80A01H501U" }
    notes { nil }
  end
end
