class Service::YarnLockfile::Scan < ::MicroService
  attribute :lockfile_path

  def call
    libs_by_line_number.each do |line_number, lib_json|
      Service::AnalyzeLibrary.call(
        name: lib_json['name'],
        version: lib_json['version'],
        type: 'JsLibrary',
        file: 'yarn.lock',
        line_number: line_number,
        # only the bootstrap scan of the most recent version of each library has completed, so
        # ignore version for now
        version_must_match: false
      )
    end
  end

  private
  def libs_by_line_number
    Service::YarnLockfile::Parse.call(lockfile_path: lockfile_path)
  end
end
