require 'rails_helper'

describe Service::CodeClimate::ReportIssue do
  let(:library) { create(:gem_library) }

  subject { Service::CodeClimate::ReportIssue.call(issue: :non_compliant, library: library, file: 'Gemfile.lock', line_number: 1 ) }
  describe "Library with non-compliant license" do
    it "reports the library with valid JSON output" do
      result = capture_stdout { subject }
      expect {JSON.parse(result) }.not_to raise_exception
      expect(JSON.parse(result)["check_name"]).to eq "Compatibility/Non-compliant license"
    end
  end
end
