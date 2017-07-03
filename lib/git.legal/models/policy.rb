# == Schema Information
#
# Table name: policies
#
#  id                    :integer          not null, primary key
#  project_id            :integer
#  allow_affero_copyleft :boolean          default(FALSE)
#  allow_strong_copyleft :boolean          default(FALSE)
#  allow_weak_copyleft   :boolean          default(TRUE)
#  allow_permissive      :boolean          default(TRUE)
#  sublicenses_comply    :boolean          default(TRUE)
#
# Indexes
#
#  index_policies_on_project_id  (project_id)
#

class Policy < ActiveRecord::Base
  belongs_to :project
  has_many :license_type_policies
  has_many :license_types, through: :license_type_policies

  def whitelist
    # use a select so we filter on license type policies not yet saved
    license_type_policies.select {|p| p.treatment == 'whitelist'}.map(&:license_type)
  end

  def blacklist
    license_type_policies.select {|p| p.treatment == 'blacklist'}.map(&:license_type)
  end

  def add_to_whitelist(license_type)
    add_to_list :whitelist, license_type
  end

  def add_to_blacklist(license_type)
    add_to_list :blacklist, license_type
  end

  private
  def add_to_list(treatment, license_type)
    self.license_type_policies << LicenseTypePolicy.new(
      policy: self,
      license_type: license_type,
      treatment: treatment
    )
  end
end
