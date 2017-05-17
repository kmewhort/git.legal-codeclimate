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
end
