# == Schema Information
#
# Table name: copyleft_clauses
#
#  id                  :integer          not null, primary key
#  license_type_id     :integer
#  copyleft_applies_to :string
#  copyleft_engages_on :string
#
# Indexes
#
#  index_copyleft_clauses_on_license_type_id  (license_type_id)
#

class CopyleftClause < ActiveRecord::Base
  belongs_to :license_type

  COPYLEFT_APPLIES_TO_TYPES = %w(modified_files derivatives derivatives_linking_excepted compilations)
  COPYLEFT_ENGAGES_ON_TYPES = %w(use affero distribution)
  validates :copyleft_applies_to, :copyleft_engages_on, presence: true, if: Proc.new {|c| c.license_type.try(:obligation).try(:obligation_copyleft) }
  validates :copyleft_applies_to, inclusion: {in: COPYLEFT_APPLIES_TO_TYPES, allow_nil: true}
  validates :copyleft_engages_on, inclusion: {in: COPYLEFT_ENGAGES_ON_TYPES, allow_nil: true}
end
