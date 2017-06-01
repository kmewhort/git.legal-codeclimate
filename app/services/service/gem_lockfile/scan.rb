class Service::GemLockfile::Scan < ::MicroService
  attribute :lockfile_path

  def call
    specs_by_line_number.each do |line_number, spec|
      Service::AnalyzeLibrary.call(
        name: spec.name,
        file: 'Gemfile.lock',
        line_number: line_number,
        # only the bootstrap scan of the most recent version of each library has completed, so
        # ignore version for now
        version_must_match: false
      )
    end
  end

  private
  def specs_by_line_number
    Service::GemLockfile::Parse.call(lockfile_contents)
  end

  def lockfile_contents
    IO.read lockfile_path
  end
end
