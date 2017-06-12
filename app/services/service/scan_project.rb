class Service::ScanProject < ::MicroService
  GEM_LOCKFILE_PATH = '/code/Gemfile.lock'
  GEMFILE_PATH = '/code/Gemfile'
  GEMSPEC_PATH = '/code/*.gemspec'
  YARN_LOCKFILE_PATH = '/code/yarn.lock'

   def call
     if File.exist? GEM_LOCKFILE_PATH
       Service::GemLockfile::Scan.call(file_path: GEM_LOCKFILE_PATH)
     elsif File.exist? GEMFILE_PATH
       Service::Gemfile::Scan.call(file_path: GEMFILE_PATH)
     elsif Dir[GEMSPEC_PATH].any?
       Service::Gemspec::Scan.call(file_path: Dir[GEMSPEC_PATH].first)
     end

    # yarn not available until the registry scan is complete
     #Service::YarnLockfile::Scan.call(lockfile_path: YARN_LOCKFILE_PATH) if File.exist? YARN_LOCKFILE_PATH
   end
end
