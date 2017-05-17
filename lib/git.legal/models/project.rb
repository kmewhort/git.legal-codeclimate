# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  project_owner_id   :integer
#  project_owner_type :string
#  name               :string
#  private            :boolean
#  language           :string
#  active             :boolean
#  github_id          :string
#  github_data        :jsonb
#  parent_name        :string
#
# Indexes
#
#  index_projects_on_active                                   (active)
#  index_projects_on_github_id                                (github_id)
#  index_projects_on_project_owner_type_and_project_owner_id  (project_owner_type,project_owner_id)
#

class Project < ActiveRecord::Base
  belongs_to :project_owner, polymorphic: true
  has_many :project_accesses
  has_many :branches, dependent: :destroy
  has_many :events, through: :branches
  has_many :libraries, through: :branches

  has_one :policy
  has_one :project_config

  # own license
  has_many :project_licenses
  has_many :licenses, through: :project_licenses

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where.not(active: true) }

  def policy_id
    policy.id.to_s
  end

  def default_branch
    result = branches.where(name: project_config.default_branch_name).first
    raise "Default branch does not exist" if result.nil?
    result
  end

  def own_license_identifier
    licenses.any? ? licenses.first.license_type.identifier : nil
  end

  def github_user
    if project_owner.is_a? User
      project_owner
    elsif project_accesses.any?
      project_accesses.first.user
    else
      raise "No github authorization for project"
    end
  end
end
