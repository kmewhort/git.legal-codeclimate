class Service::Scan < ::MicroService
  GEM_LOCKFILE_PATH = '/code/Gemfile.lock'

   def call
     Service::GemLockfile::Scan.call(lockfile_path: GEM_LOCKFILE_PATH) if File.exist? GEM_LOCKFILE_PATH
   end
end
