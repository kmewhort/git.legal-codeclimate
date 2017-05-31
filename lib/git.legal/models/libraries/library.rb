# == Schema Information
#
# Table name: libraries
#
#  id                  :integer          not null, primary key
#  type                :string
#  branch_id           :integer
#  name                :string
#  version             :string
#  approved            :boolean
#  path                :string
#  source              :string
#  approved_by_policy  :boolean
#  found_in            :string
#  package_metadata    :jsonb
#  licenses_recognized :boolean
#
# Indexes
#
#  index_libraries_on_branch_id  (branch_id)
#  index_libraries_on_type       (type)
#

class Library < ActiveRecord::Base
  belongs_to :branch
  has_many :licenses, dependent: :destroy
  has_and_belongs_to_many :dependents, class_name: "Library",
                          join_table: 'library_dependents',
                          foreign_key: 'parent_library_id',
                          association_foreign_key: 'child_library_id'
  # flag to force library to be refreshed even if not dirty
  attr_accessor :force_refresh

  def library_approval_based_on_name

    # library approvals are indexed by name and to work across the project, and
    # against changed libraries
    LibraryApproval.where(project_id: branch.project_id, library_name: name).first
  end
end

