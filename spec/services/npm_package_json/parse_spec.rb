require 'rails_helper'

describe Service::NpmPackageJson::Parse do
  let(:package_json_path) { Rails.root.join('spec','fixtures','npm_package_json','package.json') }
  let(:file_contents) { IO.read(package_json_path) }
  subject { Service::NpmPackageJson::Parse.call(file_contents: file_contents) }

  it "finds the libraries listed in the package.json" do
    expect(subject.count).to eq 22
  end

  it "finds the line number where a gem is reported" do
    expect(subject[0][:name]).to eq 'ember-cli'
    expect(subject[0][:line]).to eq 31
  end
end
