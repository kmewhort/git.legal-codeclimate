class Service::GemLockfile::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_rubygems".to_sym
    super
  end

  protected
  def library_identifiers
    Service::GemLockfile::Parse.call(file_contents)
  end

  def library_class
    'GemLibrary'
  end
end
