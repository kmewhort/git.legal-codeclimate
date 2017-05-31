require 'spec_helper'

describe 'End to end' do
  let(:test_code_path) { "#{File.dirname(__FILE__)}/fixtures/gemfile_lock" }

  subject { JSON.parse `codeclimate analyze --dev -f json -e git.legal #{test_code_path}` }

  context "no config file provided" do
    it "reports issues for affero and strong copyleft licenses" do
    end

    it "does not report issues for weak copyleft and permissive licenses" do

    end

    it "reports issues for unknown libraries" do
      issue = subject.find {|issue| issue['description'] =~ /virtus/}
      expect(issue['check_name']).to eq 'Compatibility/Unrecognized library'
    end
  end

  context "config file prohibits weak copyleft" do

  end

  context "config file allows unknown libraries" do

  end
end
