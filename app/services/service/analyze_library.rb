class Service::AnalyzeLibrary < ::MicroService
  attribute :library
  attribute :file
  attribute :line_number
  attribute :version_must_match, Boolean, default: true

  def call
    if library.licenses.blank?
      report_license_not_found
    elsif licenses_unrecognized?
      report_license_unrecognized
    elsif !licenses_within_policy?
      report_non_compliant
    end
  end

  private
  def report_license_not_found
    Service::CodeClimate::ReportIssue.call(issue: :license_not_found, library: library, file: file, line_number: line_number)
  end

  def report_license_unrecognized
    Service::CodeClimate::ReportIssue.call(issue: :license_unrecognized, library: library, file: file, line_number: line_number)
  end

  def report_non_compliant
    Service::CodeClimate::ReportIssue.call(issue: :non_compliant, library: library, file: file, line_number: line_number)
  end

  def licenses_unrecognized?
    license_types.all? {|lt| !lt.confirmed }
  end

  def licenses_within_policy?
    Service::Approvals::CheckPolicyApproval.call(
      policy: policy,
      license_types: license_types
    )
  end

  def license_types
    @license_types ||= begin
      license_type_ids = library.licenses.pluck(:license_type_id)
      LicenseType.where(id: license_type_ids)
    end
  end

  def policy
    @policy ||= Service::CodeClimate::LoadLicensePolicy.call
  end
end
