require 'rails_helper'

describe Service::YarnLockfile::Parse do
  let(:lockfile_path) { Rails.root.join('spec','fixtures','yarn_lock','yarn.lock') }

  subject { Service::YarnLockfile::Parse.call(lockfile_path: lockfile_path) }

  it "finds the specs listed in the lockfile" do
    expect(subject.count).to eq 160
  end

  it "finds the line number where a spec is reported" do
    expect(subject[5]['name']).to eq 'ajv'
  end
end
