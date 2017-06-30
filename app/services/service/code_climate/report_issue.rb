class Service::CodeClimate::ReportIssue < ::MicroService
  attribute :issue
  attribute :library
  attribute :file
  attribute :line_number

  def call
    @data = case issue
      when :non_compliant
        non_compliant_data
      when :library_not_found
        library_not_found_data
      when :license_not_found
        license_not_found_data
      when :license_unrecognized
        license_unrecognized_data
      else
        raise "Unknown issue type"
    end

    show_license_expired_message if product_license.try(:expired?)

    show_detailed_content if product_license && !product_license.expired?

    puts "#{@data.to_json}\0"
  end

  private
  def non_compliant_data
    base_data.merge({
      "check_name": "Compatibility/Non-compliant license",
      "description": "Library `#{library_name}` is licensed under #{
        license_names.count == 1 ? 'a non-compliant license' : 'non-compliant licenses'
      }: `#{license_names.to_sentence}`"
    })
  end

  def license_unrecognized_data
    base_data.merge({
      "check_name": "Compatibility/Unrecognized license",
      "description": "Library `#{library_name}` contains unrecogonized licenses: `#{license_names.to_sentence}`"
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
      "description": "No licenses found for `#{library_name}`. Either the library reports the licenses in an unsupported format, or the library is unlicensed."
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

  def license_names
    license_types.map(&:full_title)
  end

  def license_types
    library.licenses.map(&:license_type).uniq
  end

  def library_name
    library.name
  end

  def content
    declarations_view = IO.read Rails.root.join('app','views','license_declarations.md.erb')
    markdown = ERB.new(declarations_view).result(binding)

    {
      body: markdown
    }
  end

  def show_license_expired_message
    @data[:description] = 'Your Git.legal Pro license has expired.  Please visit our website at https://git.legal to contact the product team and renew the product.'
  end

  def show_detailed_content
    if issue.in? [:non_compliant, :license_unrecognized]
      @data[:content] = content
    end
  end

  def product_license
    @product_license ||= Service::LoadProductLicense.call
  end
end
