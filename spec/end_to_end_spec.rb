require 'spec_helper'

describe 'End to end' do
  # docker can't connect to /var/folders/... on OSX, so use the project tmpdir
  ENV['TMPDIR'] = "#{File.dirname(__FILE__)}/../tmp"

  let(:tmp_code_dir) { Dir.mktmpdir }
  let(:gemfile_lock) { "#{File.dirname(__FILE__)}/fixtures/gemfile_lock/Gemfile.lock" }

  before do
    FileUtils.cp gemfile_lock, tmp_code_dir
  end

  subject {
    JSON.parse `cd #{tmp_code_dir} && codeclimate analyze --dev -f json -e git.legal`
  }

  def reported_issue_for(library_name)
    # we always report the library in the description, so search on that
    subject.find {|issue| issue['description'] =~ /#{library_name}/}
  end

  context "default config" do
    before do
      IO.write "#{tmp_code_dir}/.codeclimate.yml", <<~YML
        ---
        engines:
          git.legal:
            enabled: true
      YML
    end

    it "reports issues for affero and strong copyleft licenses" do
      expect(reported_issue_for('colorize')['check_name']).to eq 'Compatibility/Non-compliant license'
      expect(reported_issue_for('nuggets')['check_name']).to eq 'Compatibility/Non-compliant license'
    end

    it "does not report issues for weak copyleft and permissive licenses" do
      expect(reported_issue_for('sqlite3')).to eq nil
      expect(reported_issue_for('origami')).to eq nil
    end

    it "reports issues for unknown libraries" do
      expect(reported_issue_for('localgem_4525')['check_name']).to eq 'Compatibility/Unrecognized library'
    end
  end

  context "config file prohibits weak copyleft" do
    before do
      IO.write "#{tmp_code_dir}/.codeclimate.yml", <<~YML
        ---
        engines:
          git.legal:
            enabled: true
            config:
              allow_weak_copyleft: false
      YML
    end

    it "report issues for weak copyleft licenses" do
      expect(reported_issue_for('origami')['check_name']).to eq 'Compatibility/Non-compliant license'
    end
  end

  context "config file allows unknown libraries" do
    before do
      IO.write "#{tmp_code_dir}/.codeclimate.yml", <<~YML
        ---
        engines:
          git.legal:
            enabled: true
            config:
              allow_unknown_libraries: true
      YML
    end

    it "does not report issues for unknown libraries" do
      expect(reported_issue_for('localgem_4525')).to eq nil
    end
  end
end
