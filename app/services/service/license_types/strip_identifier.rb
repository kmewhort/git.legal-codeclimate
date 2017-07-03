require 'micro_service'
class Service::LicenseTypes::StripIdentifier < ::MicroService
  attribute :identifier, String

  def call
    result = identifier.to_s.downcase

    # remove any ".0" from a version at the end
    result.gsub! /\.0\)?$/, ''

    # remove anything in parenthesis
    result.gsub! /([\w\d]+)\s*[\(\<].*/, '\1'

    # strip dashes, spaces, etc for searching
    result.gsub! /[^a-z0-9]/,''

    # remove any "license" or "licensed" on the end
    result.gsub! /licen[sc]ed?$/, ''

    # remove any "the" from the start
    result.gsub! /^the/, ''

    result
  end
end
