class Service::Gemfile::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_rubygems".to_sym
    self.follow_dependencies = true
    super
  end

  protected
  def library_identifiers
    Service::Gemspec::Parse.call(file_contents: file_contents)
  end

  def library_class
    'GemLibrary'
  end
end
