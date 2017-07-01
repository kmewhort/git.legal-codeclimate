class LicenseTypePolicy < ActiveRecord::Base
  belongs_to :policy
  belongs_to :license_type
end
