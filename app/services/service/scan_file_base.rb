class Service::ScanFileBase < ::MicroService
  attribute :file_path

  def call
    library_identifiers.each do |lib_info|
      Service::AnalyzeLibrary.call(
        name: lib_info[:name],
        version: lib_info[:version],
        type: library_class,
        file: File.basename(file_path),
        line_number: lib_info[:line],
        version_must_match: false
      )
    end
  end

  protected
  # array of hashes with the :name, :version and :line_number
  def library_identifiers
    raise "Pure virtual"
  end

  def library_class
    raise "Pure virtual"
  end
end
