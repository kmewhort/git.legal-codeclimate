class Service::CodeClimate::ReportIssue < ::MicroService
  attribute :issue
  attribute :library
  attribute :file
  attribute :line_number

  def call
    data = case issue
      when :non_compliant
        non_compliant_data
      when :library_not_found
        library_not_found_data
      when :license_not_found
        license_not_found_data
      else
        raise "Unknown issue type"
    end

    puts "#{data.to_json}\0"
  end

  def non_compliant_data
    base_data.merge({
      "check_name": "Compatibility/Non-compliant license",
      "description": "`#{library_name}`s falls under non-compliant licenses: `#{license_names}`"
    })
  end

  def library_not_found_data
    base_data.merge({
      "check_name": "Compatibility/Unrecognized library",
      "description": "Unknown library `#{library_name}`. Unable to determine license compliance."
    })
  end

  def license_not_found_data
    base_data.merge({
      "check_name": "Compatibility/No licenses",
      "description": "No licenses found for `#{library_name}`. Either the license is specified in an unsupported format, or the library is unlicensed"
    })
  end

  def base_data
    {
      "type": "issue",
      "categories": ["Compatibility"],
      "location": {
        "path": file,
        "lines": {
          "begin": line_number,
          "end": line_number
        }
      },
      "fingerprint": library_name
    }
  end

  def license_name
    library.licenses.map {|license| license.license_type.identifier}.to_sentence
  end

  def library_name
    library.name
  end

  def content
    # TODO
    nil
  end
end
