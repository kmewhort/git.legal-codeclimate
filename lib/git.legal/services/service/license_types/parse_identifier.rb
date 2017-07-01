require 'micro_service'
class Service::LicenseTypes::ParseIdentifier < ::MicroService
  attribute :identifier, String

  # parse out the abbreviation and version number from a raw string identifier
  def call
    return nil if reject?

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

  private
  def reject?
    # we're scanning the LICENSE.TXT anyways, so skip over a reference to it
    return true if identifier =~ /^SEE\s*(LICEN[SC]E)?\s*/i
    # skip over references to files
    return true if identifier =~ /^[\.\/]/
    # reference to "SPDX license" is not a license identifier
    return true if identifier =~ /SPDX/
    # "license" by itself is not an identifier
    return true if identifier =~ /^\s*licen[sc]e\s*$/i

    false
  end
end
