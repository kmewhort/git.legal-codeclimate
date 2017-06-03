require 'rails_helper'

describe Service::GemLockfile::Parse do
  let(:lockfile_path) { Rails.root.join('spec','fixtures','gemfile_lock','Gemfile.lock') }
  let(:lockfile_contents) { IO.read lockfile_path }

  subject { Service::GemLockfile::Parse.call(lockfile_contents) }

  it "finds the specs listed in the lockfile" do
    expect(subject.count).to eq 9
  end

  it "finds the line number where a spec is reported" do
    expect(subject[9].name).to eq 'colorize'
  end
end
