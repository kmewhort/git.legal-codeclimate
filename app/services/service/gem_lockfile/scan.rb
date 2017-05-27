class Service::GemLockfile::Scan < ::MicroService
  attribute :lockfile_path

  def call
    specs_by_line_number.each do |line_number, spec|
      library = Library.where(name: spec.name, version: spec.version.to_s).first

      if library.nil?
        unknown_lib = Library.new(name: spec.name, version: spec.version.to_s)
        Service::CodeClimate::ReportIssue.call(issue: :library_not_found, library: unknown_lib, file: 'Gemfile.lock', line_number: line_number)
      elsif library.licenses.nil?
        Service::CodeClimate::ReportIssue.call(issue: :license_not_found, library: library, file: 'Gemfile.lock', line_number: line_number)
      elsif licenses_within_policy?(library)
        Service::CodeClimate::ReportIssue.call(issue: :non_compliant, library: library, file: 'Gemfile.lock', line_number: line_number)
      end
    end
  end

  private
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
