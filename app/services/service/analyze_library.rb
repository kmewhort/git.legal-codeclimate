class Service::AnalyzeLibrary < ::MicroService
  attribute :name
  attribute :version
  attribute :type
  attribute :file
  attribute :line_number
  attribute :version_must_match, Boolean, default: true

  def call
    if matching_library.nil?
      report_library_not_found unless policy.allow_unknown_libraries
    elsif matching_library.licenses.blank?
      report_license_not_found
    elsif !licenses_within_policy?
      report_non_compliant
    end
  end

  private
  def matching_library
    @matching_library ||= begin
      if version_must_match && !version.blank?
        Library.where(name: name, type: type, version: version).first
      else
        # use the latest version that has actually specified a license
        Library.where(name: name, type: type).order(version: :desc).to_a.find {|l| l.licenses.present?}
      end
    end
  end

  def report_library_not_found
    unknown_lib = Library.new(name: name, version: version)
    Service::CodeClimate::ReportIssue.call(issue: :library_not_found, library: unknown_lib, file: file, line_number: line_number)
  end

  def report_license_not_found
    Service::CodeClimate::ReportIssue.call(issue: :license_not_found, library: matching_library, file: file, line_number: line_number)
  end

  def report_non_compliant
    Service::CodeClimate::ReportIssue.call(issue: :non_compliant, library: matching_library, file: file, line_number: line_number)
  end

  def licenses_within_policy?
    Service::Approvals::CheckPolicyApproval.call(
      policy: policy,
      license_types: license_types
    )
  end

  def license_types
    license_type_ids = matching_library.licenses.pluck(:license_type_id)
    LicenseType.where(id: license_type_ids)
  end

  def policy
    @policy ||= Service::CodeClimate::LoadLicensePolicy.call
  end
end
