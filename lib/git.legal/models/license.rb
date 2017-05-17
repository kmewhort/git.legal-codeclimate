# == Schema Information
#
# Table name: licenses
#
#  id                       :integer          not null, primary key
#  library_id               :integer
#  license_type_id          :integer
#  referencer_type          :string
#  referencer_id            :string
#  authors                  :string           is an Array
#  unknown_version          :boolean
#  from_more_recent_library :boolean
#  text_file_name           :string
#  text_content_type        :string
#  text_file_size           :integer
#  text_updated_at          :datetime
#  temporary                :boolean          default(FALSE)
#
# Indexes
#
#  index_licenses_on_library_id       (library_id)
#  index_licenses_on_license_type_id  (license_type_id)
#

class License < ActiveRecord::Base
  belongs_to :library
  belongs_to :license_type

  # for licenses that belong to a project directly (not one of a project's libraries)
  has_one :project_license

  REFERENCER_TYPES = %w(gem_spec readme_mention readme_section dot_txt remote_dot_txt comment_mention)

  has_attached_file :text,
                    styles: { unparsed: { format: nil },
                              html: { format: 'html' },
                              text: { format: 'txt' } },
                    processors: [:license_text_processor],
                    path: Rails.configuration.private_paperclip_path
  do_not_validate_attachment_file_type :text

  validates_presence_of :license_type, unless: :temporary
end
