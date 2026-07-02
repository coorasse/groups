FactoryBot.define do
  factory :group do
    event
    date { Date.current }
    time { "10:00" }
    status { :open }
  end
end
