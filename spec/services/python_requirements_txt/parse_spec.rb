require 'rails_helper'

describe Service::PythonRequirementsTxt::Parse do
  let(:package_json_path) { Rails.root.join('spec','fixtures','python_requirements_txt','requirements.txt') }
  let(:file_contents) { IO.read(package_json_path) }
  subject { Service::PythonRequirementsTxt::Parse.call(file_contents: file_contents) }

  it "finds the libraries listed in the package.json" do
    expect(subject.count).to eq 47
  end

  it "finds the line number where a gem is reported" do
    expect(subject[10][:name]).to eq 'Flask-Compress'
    expect(subject[10][:line]).to eq 11
  end
end
