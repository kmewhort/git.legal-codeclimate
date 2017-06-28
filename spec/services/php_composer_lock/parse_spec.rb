require 'rails_helper'

describe Service::PhpComposerLock::Parse do
  let(:package_json_path) { Rails.root.join('spec','fixtures','composer_lock','composer.lock') }
  let(:file_contents) { IO.read(package_json_path) }
  subject { Service::PhpComposerLock::Parse.call(file_contents: file_contents) }

  it "finds the libraries listed in the composer.lock" do
    expect(subject.count).to eq 7
  end

  it "finds the line number where a gem is reported" do
    expect(subject[0][:name]).to eq 'bower-asset/jquery'
    expect(subject[0][:line]).to eq 10
  end
end
