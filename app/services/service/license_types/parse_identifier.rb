require 'micro_service'
class Service::LicenseTypes::ParseIdentifier < ::MicroService
  attribute :identifier, String

  # parse out the abbreviation and version number from a raw string identifier
  def call
    @abbrev = @version = nil
    match = identifier.match /(.*?)\s*,?\s*\(?([Vv]?(?:ersion)?\-?\s*[\d\.]+)?[\+\)\s]*$/
    return nil if match.nil?

    name = match[1]
    version = match[2]

    # handle special case for X11 (the 11 gets interpeted as a version number)
    if (name.last == 'X') && (version == '11')
      name = name + version
      version = nil
    end

    {
      abbreviation: name,
      version: version.blank? ? nil : version.gsub(/^\D+/,'').gsub(/\D+$/,'').gsub(/\D+/,'.')
    }
  end
end
