# == Schema Information
#
# Table name: license_types
#
#  id                     :integer          not null, primary key
#  title                  :string
#  version                :float
#  identifier             :string
#  identifiers            :string           is an Array
#  searchable_identifiers :string           is an Array
#  unverified             :boolean          default(TRUE)
#  domain_content         :boolean
#  domain_data            :boolean
#  domain_software        :boolean
#  maintainer             :boolean
#  maintainer_type        :string
#  url                    :string
#  created_at             :datetime
#  updated_at             :datetime
#  logo_file_name         :string
#  logo_content_type      :string
#  logo_file_size         :integer
#  logo_updated_at        :datetime
#  text_file_name         :string
#  text_content_type      :string
#  text_file_size         :integer
#  text_updated_at        :datetime
#
# Indexes
#
#  index_license_types_on_identifier              (identifier)
#  index_license_types_on_identifiers             (identifiers)
#  index_license_types_on_searchable_identifiers  (searchable_identifiers)
#

require "#{Rails.root}/lib/paperclip/license_text_processor"
class LicenseType < ActiveRecord::Base
  has_many :licenses, dependent: :destroy
  has_many :license_type_approvals, dependent: :destroy

  CHILDREN = [:compliance, :right, :obligation, :patent_clause, :attribution_clause, :copyleft_clause,
   :compatibility, :termination, :changes_to_term, :disclaimer, :conflict_of_law]
  CHILDREN.each {|child_class| has_one child_class, dependent: :destroy }
  accepts_nested_attributes_for *CHILDREN

  scope :confirmed, -> { where(confirmed: true) }

  before_save :generate_searchable_identifiers
  before_save do |lt|
    lt.confirmed = lt.detailed_info?
  end

  has_attached_file :logo, styles: { medium: "220x220" }
  validates_attachment :logo, content_type:  { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"] }

  has_attached_file :text, styles: { unparsed: { format: nil },
                                     html: { format: 'html' },
                                     text: { format: 'txt' } },
                            processors: [:license_text_processor]
  validates_attachment :text, content_type: { content_type: ["text/html", "text/plain"] }

  validates :identifier, :title, presence: true

  MAINTAINER_TYPES = %w(gov ngo private)
  validates :maintainer_type, inclusion: MAINTAINER_TYPES, allow_nil: true

  # full title w/ licence version identifier
  def full_title
    return title if version.nil?

    full_title = title + ' ' + version.to_s
  end

  # original text of the licence (as html)
  def fulltext_filename
    self.text.path(:html)
  end

  # get all versions of the this licence
  def all_versions
    result = LicenseType.where(identifier: self.identifier).reject{|l| l.version.nil? }
    return [] if result.empty?

    # special case handling for LGPL, which changed names from 2.0 to 2.1
    if title == 'GNU Library General Public License'
      result += Licence.where(title: 'GNU Lesser General Public License')
    elsif title == 'GNU Lesser General Public License'
      result += Licence.where(title: 'GNU Library General Public License')
    end

    # sort by version
    result.sort! { |a,b| a.version <=> b.version }
    # special case for BSD, which has decreasing number of clauses labels with future versions
    if title == 'BSD'
      result.reverse!
    end
    result
  end

  def build_children
    # build each of the child objects if they don't exist
    self.class::CHILDREN.each do |child|
      self.send "build_#{child}" if self.send(child).nil?
    end
  end

  def detailed_info?
    # if detailed info is filled in, a domain must be selected
    domain_content || domain_data || domain_software
  end

  def copyleft?
    return nil unless detailed_info?

    obligation.obligation_copyleft
  end

  def permissive?
    return nil unless detailed_info?

    !copyleft?
  end

  def weak_copyleft?
    return nil unless detailed_info?

    copyleft? &&
      copyleft_clause.copyleft_applies_to.in?(['derivatives_linking_excepted', 'modified_files']) &&
      !affero_copyleft?
  end

  def strong_copyleft?
    return nil unless detailed_info?

    copyleft? && !weak_copyleft? && !affero_copyleft?
  end

  def affero_copyleft?
    return nil unless detailed_info?

    copyleft? && (copyleft_clause.copyleft_engages_on == 'affero')
  end

  def approval_for_project(project)
    license_type_approvals.where(project: project).first
  end

  def generate_searchable_identifiers
    # include the identifiers and the title (all of them stripped)
    self.searchable_identifiers = self.identifiers + [self.title]
    self.searchable_identifiers = self.searchable_identifiers.map { |ident| Service::LicenseTypes::StripIdentifier.call(identifier: ident) }
  end
end

