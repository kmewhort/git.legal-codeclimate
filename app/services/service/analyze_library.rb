class Service::AnalyzeLibrary < ::MicroService
  attribute :name
  attribute :version
  attribute :file
  attribute :line_number

  def call
    @library = Library.where(name: name, version: version).first

    if @library.nil?
      report_library_not_found unless policy.allow_unknown_libraries
    elsif @library.licenses.nil?
      report_license_not_found
    elsif licenses_within_policy?
      report_non_compliant
    end
  end

  private
  def report_library_not_found
    unknown_lib = Library.new(name: name, version: version)
    Service::CodeClimate::ReportIssue.call(issue: :library_not_found, library: unknown_lib, file: file, line_number: line_number)
  end

  def report_license_not_found
    Service::CodeClimate::ReportIssue.call(issue: :license_not_found, library: @library, file: file, line_number: line_number)
  end

  def report_non_compliant(library, line_number)
    Service::CodeClimate::ReportIssue.call(issue: :non_compliant, library: @library, file: file, line_number: line_number)
  end

  def licenses_within_policy?
    Service::Approvals::CheckPolicyApproval(
      policy: policy,
      license_types: license_types
    )
  end

  def license_types
    license_type_ids = @library.licenses.pluck(:license_type_id)
    LicenseType.where(id: license_type_ids)
  end

  def policy
    @policy ||= Service::CodeClimate::LoadLicensePolicy.call
  end
end
