require 'rails_helper'

describe Service::Gemfile::Parse do
  let(:gemfile_path) { Rails.root.join('spec','fixtures','gemfile_lock','Gemfile') }
  let(:file_contents) { IO.read(gemfile_path) }
  subject { Service::Gemfile::Parse.call(file_contents: file_contents) }

  it "finds the gems listed in the Gemfile" do
    # looks like the Gemnasium parser doesn't capture "path" gems on the local drive...OK for now
    expect(subject.count).to eq 5
  end

  it "finds the line number where a gem is reported" do
    expect(subject[0][:name]).to eq 'sqlite3'
    expect(subject[0][:line]).to eq 4
  end
end
