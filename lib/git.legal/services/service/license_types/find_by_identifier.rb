require 'micro_service'
class Service::LicenseTypes::FindByIdentifier < ::MicroService
  attribute :identifier, String
  attribute :create_if_not_found, Boolean, default: true
  attribute :confirmed_only, Boolean, default: false

  # returns the license type, or multiple license types if ambiguous; if none found,
  # creates a new unverified license type
  def call
    return nil if identifier.blank?

    @parse_result = Service::LicenseTypes::ParseIdentifier.call(identifier: identifier)
    return nil if @parse_result.nil?

    types = find_license_types(@parse_result[:abbreviation], @parse_result[:version])

    if create_if_not_found && types.empty? && !@parse_result[:abbreviation].empty?
      types = [create_new_type]
    end

    types
  end

  private
  def find_license_types(identifier, version = nil)
    searchable_identifier = Service::LicenseTypes::StripIdentifier.call(identifier: identifier)
    licenses = LicenseType.confirmed.where("? = ANY(searchable_identifiers)", searchable_identifier)
    licenses = licenses.where(version: version) unless version.blank?

    # sometimes a trailing number in the identifier is incorrectly parsed as a version - eg.
    # CC0 or BSD-3, so try searching the identifiers with the version at the end as well
    if licenses.empty? && !version.blank?
      licenses = LicenseType.confirmed.where("? = ANY(searchable_identifiers)", searchable_identifier + version)
    end

    # only search unconfirmed if there no confirmed ones are found
    if licenses.empty? && !confirmed_only
      licenses = LicenseType.where("? = ANY(searchable_identifiers)", searchable_identifier)
      licenses = licenses.where(version: version) unless version.blank?
    end

    licenses.order(version: :desc)
  end

  def create_new_type
    if @parse_result.nil?
      raise "Unable to parse identifier #{@parse_result[:abbreviation]}"
    end

    LicenseType.create!(
      title: @parse_result[:abbreviation],
      version: @parse_result[:version],
      identifier: @parse_result[:abbreviation],
      identifiers: [@parse_result[:abbreviation]],
      unverified: true
    )
  end
end
