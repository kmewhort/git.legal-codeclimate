require 'rails_helper'

describe Service::Gemfile::Scan do
  let(:gemfile_path) { Rails.root.join('spec','fixtures','gemfile_lock','Gemfile') }
  let(:rubygems_project) { create(:project, name: 'rubygems_license_db') }
  let!(:indirect_library) {
    create(:gem_library,
           branch: rubygems_project.branches.first,
           name: 'prawn', version: '1.0.0')
  }
  let!(:direct_library) {
    create(:gem_library,
           branch: rubygems_project.branches.first,
           name: 'thinreports', version: '1.3.12',
           dependents: [indirect_library])
  }

  subject { Service::Gemfile::Scan.call(file_path: gemfile_path) }

  it "analyzes the directly included libraries" do
    expect(Service::AnalyzeLibrary).to receive(:call) do |args|
      expect(args[:library].name).to eq 'thinreports'
      expect(args[:line_number]).to eq 7
    end
    expect(Service::AnalyzeLibrary).to receive(:call)

    subject
  end

  it "analyses dependencies of included libraries" do
    expect(Service::AnalyzeLibrary).to receive(:call)
    expect(Service::AnalyzeLibrary).to receive(:call) do |args|
      expect(args[:library].name).to eq 'prawn'
      expect(args[:line_number]).to eq 7
    end

    subject
  end
end
