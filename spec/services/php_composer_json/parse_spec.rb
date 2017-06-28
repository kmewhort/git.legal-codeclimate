require 'rails_helper'

describe Service::PhpComposerJson::Parse do
  let(:package_json_path) { Rails.root.join('spec','fixtures','composer_lock','composer.json') }
  let(:file_contents) { IO.read(package_json_path) }
  subject { Service::PhpComposerJson::Parse.call(file_contents: file_contents) }

  it "finds the libraries listed in the package.json" do
    expect(subject.count).to eq 11
  end

  it "finds the line number where a gem is reported" do
    expect(subject[7][:name]).to eq 'bower-asset/jquery'
    expect(subject[7][:line]).to eq 78
  end
end
