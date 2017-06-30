require 'rails_helper'

describe Service::CodeClimate::ReportIssue do
  let(:library) { create(:gem_library) }
  let!(:license) { create(:license, library: library) }
  subject {
    capture_stdout { Service::CodeClimate::ReportIssue.call(
      issue: :non_compliant,
      library: library,
      file: 'Gemfile.lock',
      line_number: 1 )
    }.gsub(/\0$/, '')
  }

  describe "Library with non-compliant license" do
    it "reports the library with valid JSON output" do
      expect {JSON.parse(subject) }.not_to raise_exception
      expect(JSON.parse(subject)["check_name"]).to eq "Compatibility/Non-compliant license"
    end

    context "no license" do
      it "does not output a detailed content body" do
        expect(JSON.parse(subject)['content']).to be nil
      end
    end

    context "pro license" do
      before do
        allow(Service::LoadProductLicense).to receive(:call).and_return(double('expired?' => false))
      end

      it "renders a valid markdown document (NOTE: requires manual verification)" do
        # all strings are valid in markdown format, so best we can do is write to a test file for manual
        # venification
        content_markdown = JSON.parse(subject)['content']['body']
        tempfile = Rails.root.join('tmp', 'markdown-content-test.md')
        IO.write tempfile, content_markdown
        puts "*** Markdown written to #{tempfile} for manual verification ***"
      end
    end
  end
end
