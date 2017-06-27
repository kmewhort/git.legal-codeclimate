class Service::ScanProject < ::MicroService
  GEM_LOCKFILE_PATH = 'Gemfile.lock'
  GEMFILE_PATH = 'Gemfile'
  GEMSPEC_PATH = '*.gemspec'
  YARN_LOCKFILE_PATH = 'yarn.lock'
  NPM_PACKAGE_JSON_PATH = 'package.json'
  PYTHON_REQUIREMENTS_PATH = 'requirements.txt'

   def call
     if file_found? GEM_LOCKFILE_PATH
       Service::GemLockfile::Scan.call(file_path: File.join(root, GEM_LOCKFILE_PATH))
     elsif file_found? GEMFILE_PATH
       Service::Gemfile::Scan.call(file_path: File.join(root, GEMFILE_PATH))
     elsif file_found? gemspec_file
       Service::Gemspec::Scan.call(file_path: File.join(root, gemspec_file))
     end

     if file_found? YARN_LOCKFILE_PATH
       Service::YarnLockfile::Scan.call(file_path: File.join(root, YARN_LOCKFILE_PATH))
     end

     if file_found? NPM_PACKAGE_JSON_PATH
       Service::NpmPackageJson::Scan.call(file_path: File.join(root, NPM_PACKAGE_JSON_PATH))
     end

     if file_found? PYTHON_REQUIREMENTS_PATH
       Service::PythonRequirementsTxt::Scan.call(file_path: File.join(root, PYTHON_REQUIREMENTS_PATH))
     end
   end

  private
  def file_found?(file)
    return false if file.nil?
    File.exist?(File.join(root, file)) && file_included?(file)
  end

  def file_included?(file)
    include_paths.include?("./") || include_paths.include?(file)
  end

  def gemspec_file
    @gemspec_file ||= begin
      path = Dir[File.join(root, GEMSPEC_PATH)].first
      path.present? ? path.sub(root, '') : nil
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
