FactoryGirl.define do
  factory :license do
    referencer_id "readme"
    referencer_type :readme_mention

    association :license_type
  end
end
