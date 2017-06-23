FactoryGirl.define do
  factory :gem_library do
    name "rails"
    version "4.2.1"

    association :license
  end
end
