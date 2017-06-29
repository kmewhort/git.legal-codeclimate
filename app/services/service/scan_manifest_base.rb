class Service::ScanManifestBase < ::MicroService
  attribute :file_path
  attribute :follow_dependencies, Boolean, default: false
  attribute :version_must_match, Boolean, default: false

  def call
    library_identifiers.each do |lib_info|
      library = Service::FindLibrary.call(
        name: lib_info[:name],
        version: lib_info[:version],
        type: library_class,
        version_must_match: version_must_match
      )

      if library.blank?
        report_library_not_found(lib_info[:name], lib_info[:version], lib_info[:line])
      else
        analyze_library(library, lib_info[:line])
      end
    end
  end

  protected
  def analyze_library(library, line_number)
    Service::AnalyzeLibrary.call(
      library: library,
      file: file_basename,
      line_number: line_number
    )

    already_scanned_libraries[library.id] = true

    if follow_dependencies
      library.dependents.each do |dependency|
        next if already_scanned_libraries.has_key? dependency.id
        analyze_library(dependency, line_number)
      end
    end
  end

  def report_library_not_found(name, version, line_number)
    return if policy.allow_unknown_libraries

    unknown_lib = Library.new(name: name, version: version)
    Service::CodeClimate::ReportIssue.call(issue: :library_not_found, library: unknown_lib, file: file_basename, line_number: line_number)
  end

  def already_scanned_libraries
    @already_scanned_ids ||= {}
  end

  # array of hashes with the :name, :version and :line_number
  def library_identifiers
    raise "Pure virtual"
  end

  def library_class
    raise "Pure virtual"
  end

  def file_contents
    IO.read file_path
  end

  def file_basename
    File.basename(file_path)
  end

  def policy
    @policy ||= Service::CodeClimate::LoadLicensePolicy.call
  end
end
