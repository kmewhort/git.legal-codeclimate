# == Schema Information
#
# Table name: branches
#
#  id                    :integer          not null, primary key
#  project_id            :integer
#  name                  :string
#  local_mount_directory :string
#  git_ref               :string
#  git_description       :string
#  active                :boolean
#  scanned               :boolean          default(FALSE)
#

class Branch < ActiveRecord::Base
  belongs_to :project
  has_many :libraries, dependent: :destroy
  has_many :events

  def url
    "#{Rails.application.routes.url_helpers.project_url(project)}?a=/project/libraries/branch/#{CGI.escape(self.name)}"
  end

  def last_scan_start_time
    last_scan_event = events.where(type: 'Event::AnalysisStarted').order('created_at DESC').first
    last_scan_event.try(:created_at)
  end

  def last_scan_end_time
    last_scan_event = events.where(type: 'Event::AnalysisComplete').order('created_at DESC').first
    last_scan_event.try(:created_at)
  end
end
