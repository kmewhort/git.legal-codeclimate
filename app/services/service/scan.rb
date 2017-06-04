class Service::Scan < ::MicroService
  GEM_LOCKFILE_PATH = '/code/Gemfile.lock'
  YARN_LOCKFILE_PATH = '/code/yarn.lock'

   def call
     Service::GemLockfile::Scan.call(lockfile_path: GEM_LOCKFILE_PATH) if File.exist? GEM_LOCKFILE_PATH
    # yarn not available until the registry scan is complete
     #Service::YarnLockfile::Scan.call(lockfile_path: YARN_LOCKFILE_PATH) if File.exist? YARN_LOCKFILE_PATH
   end
end
