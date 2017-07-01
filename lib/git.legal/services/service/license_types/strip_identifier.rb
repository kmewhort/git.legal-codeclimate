require 'micro_service'
class Service::LicenseTypes::StripIdentifier < ::MicroService
  attribute :identifier, String

  def call
    result = identifier.to_s.downcase

    # remove any "-style"
    result.gsub! /\s*\-?style/i, ''

    # remove any ".0" from a version at the end
    result.gsub! /\.0\)?$/, ''

    # remove anything in parenthesis
    result.gsub! /([\w\d]+)\s*[\(\<].*/, '\1'

    # strip dashes, spaces, etc for searching
    result.gsub! /[^a-z0-9]/,''

    # remove any "copyright" (often capitalized and occasionally picked up if in one sentence with the identifier)
    result.gsub!  /copyright$/, ''

    # remove any "open source license" on the end
    result.gsub! /opensourcelicen[sc]e/, ''

    # remove any "software license" on the end
    result.gsub! /softwarelicen[sc]e/, ''

    # remove any "license" or "licensed" on the end
    result.gsub! /licen[sc]ed?$/, ''

    # remove any "license" on the start
    result.gsub! /^licen[sc]e/, ''

    # remove any "the" from the start
    result.gsub! /^the/, ''

    # remove any "contributors" from the start (as in Contributor's ___ license)
    result.gsub! /^contributors/, ''

    result
  end
end
