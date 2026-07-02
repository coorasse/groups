FactoryBot.define do
  factory :sys_manager do
    sequence(:email_address) { |n| "manager#{n}@example.com" }
    password { "password" }
  end
end
