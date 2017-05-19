require 'rails_helper'

describe Service::GemLockfile::Parse do
  let(:lockfile_path) { Rails.root.join('spec','fixtures','Gemfile.lock') }
  let(:lockfile_contents) { IO.read lockfile_path }

  subject { Service::GemLockfile::Parse.call(lockfile_contents) }

  it "finds the specs listed in the lockfile" do
    expect(subject.count).to eq 48
  end

  it "finds the line number where a spec is reported" do
    expect(subject[4].name).to eq 'actionmailer'
  end
end
