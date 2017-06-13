FactoryGirl.define do
  factory :project do
    name 'rubygems_license_db'

    association :policy

    after(:create) do |project|
      project.branches.create!
    end
  end
end
