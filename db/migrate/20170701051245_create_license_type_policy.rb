class CreateLicenseTypePolicy < ActiveRecord::Migration
  def change
    create_table :license_type_policies do |t|
      t.references :policy, index: true
      t.references :license_type, index: true
      t.string :treatment
    end
  end
end
