class Service::ScanProject < ::MicroService
  GEM_LOCKFILE_PATH = 'Gemfile.lock'
  GEMFILE_PATH = 'Gemfile'
  GEMSPEC_PATH = '*.gemspec'
  YARN_LOCKFILE_PATH = 'yarn.lock'

   def call
     if file_found? GEM_LOCKFILE_PATH
       Service::GemLockfile::Scan.call(file_path: File.join(root, GEM_LOCKFILE_PATH))
     elsif file_found? GEMFILE_PATH
       Service::Gemfile::Scan.call(file_path: File.join(root, GEMFILE_PATH))
     elsif file_found? gemspec_file
       Service::Gemspec::Scan.call(file_path: File.join(root, gemspec_file))
     end

    # yarn not available until the registry scan is complete
     #Service::YarnLockfile::Scan.call(lockfile_path: YARN_LOCKFILE_PATH) if File.exist? YARN_LOCKFILE_PATH
   end

  private
  def file_found?(file)
    File.exist?(File.join(root, file)) && file_included?(file)
  end

  def file_included?(file)
    include_paths.include?("./") || include_paths.include?(file)
  end

  def gemspec_file
    @gemspec_file ||= begin
      path = Dir[File.join(root, GEMSPEC_PATH)].first
      path.present? ? path.sub(root) : nil
    end
  end

  def include_paths
    settings = Service::CodeClimate::GetEngineConfig.call
    settings["include_paths"]
  end

  def root
    '/code/'
  end
end
