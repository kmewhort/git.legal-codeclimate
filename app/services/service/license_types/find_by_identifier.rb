require 'micro_service'
class Service::LicenseTypes::FindByIdentifier < ::MicroService
  attribute :identifier, String
  attribute :confirmed_only, Boolean, default: false

  # returns the license type, or multiple license types if ambiguous
  def call
    return nil if identifier.blank?

    @parse_result = Service::LicenseTypes::ParseIdentifier.call(identifier: identifier)
    return nil if @parse_result.nil?

    find_license_types(@parse_result[:abbreviation], @parse_result[:version])
  end

  private
  def find_license_types(identifier, version = nil)
    searchable_identifier = Service::LicenseTypes::StripIdentifier.call(identifier: identifier)
    licenses = LicenseType.confirmed.find_by_searchable_identifier(searchable_identifier)
    licenses = licenses.where(version: version) unless version.blank?

    # sometimes a trailing number in the identifier is incorrectly parsed as a version - eg.
    # CC0 or BSD-3, so try searching the identifiers with the version at the end as well
    if licenses.empty? && !version.blank?
      licenses = LicenseType.confirmed.find_by_searchable_identifier(searchable_identifier + version)
    end

    # only search unconfirmed if there no confirmed ones are found
    if licenses.empty? && !confirmed_only
      licenses = LicenseType.find_by_searchable_identifier(searchable_identifier)
      licenses = licenses.where(version: version) unless version.blank?
    end

    licenses.order(version: :desc)
  end
end
