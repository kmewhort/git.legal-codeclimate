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

class JsLibrary < Library
end
