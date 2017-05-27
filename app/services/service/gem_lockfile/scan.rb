class Service::GemLockfile::Scan < ::MicroService
  attribute :lockfile_path

  def call
    specs_by_line_number.each do |line_number, spec|
      library = Library.where(name: spec.name, version: spec.version.to_s).first

      if library.nil?
        report_library_not_found(spec.name, spec.version.to_s, line_number) unless policy.allow_unknown_libraries
      elsif library.licenses.nil?
        report_license_not_found(library, line_number)
      elsif licenses_within_policy?(library)
        report_non_compliant(library, line_number)
      end
    end
  end

  private
  def report_library_not_found(name, version, line_number)
    unknown_lib = Library.new(name: name, version: version)
    Service::CodeClimate::ReportIssue.call(issue: :library_not_found, library: unknown_lib, file: 'Gemfile.lock', line_number: line_number)
  end

  def report_license_not_found(library, line_number)
    Service::CodeClimate::ReportIssue.call(issue: :license_not_found, library: library, file: 'Gemfile.lock', line_number: line_number)
  end

  def report_non_compliant(library, line_number)
    Service::CodeClimate::ReportIssue.call(issue: :non_compliant, library: library, file: 'Gemfile.lock', line_number: line_number)
  end

  def licenses_within_policy?(library)
    Service::Approvals::CheckPolicyApproval(
      policy: policy,
      license_types: license_types_for_library(library)
    )
  end

  def license_types_for_library(library)
    license_type_ids = library.licenses.pluck(:license_type_id)
    LicenseType.where(id: license_type_ids)
  end

  def policy
    @policy ||= Service::CodeClimate::LoadLicensePolicy.call
  end

  def specs_by_line_number
    Service::GemLockfile::Parse.call(lockfile_contents)
  end

  def lockfile_contents
    IO.read lockfile_path
  end
end
