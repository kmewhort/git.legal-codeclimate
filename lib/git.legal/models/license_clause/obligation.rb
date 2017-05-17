# == Schema Information
#
# Table name: obligations
#
#  id                         :integer          not null, primary key
#  license_type_id            :integer
#  obligation_attribution     :boolean
#  obligation_copyleft        :boolean
#  obligation_modifiable_form :boolean
#  obligation_notice          :boolean
#
# Indexes
#
#  index_obligations_on_license_type_id  (license_type_id)
#

class Obligation < ActiveRecord::Base
  belongs_to :license_type
end
