class Service::GemLockfile::Parse < Bundler::LockfileParser
  attr_accessor :specs_by_line

  # turn bundler's parser into a service (with some overrides to get the line number)
  def self.call(lockfile)
    self.new(lockfile).specs_by_line.map do |line, spec|
      {
        name: spec.name,
        version: spec.version.to_s,
        line: line
      }
    end
  end

  def initialize(lockfile)
    @gl_lockfile = lockfile
    @specs_by_line = {}

    super
  end

  private
  def parse_spec(line)
    original_specs_count = @specs.count

    super(line)

    if @specs.count > original_specs_count
      @specs_by_line[find_line_number(line)] = @current_spec
    end
  end

  def find_line_number(line_content)
    line_number = @gl_lockfile.each_line.find_index do |line_iter|
      line_iter.rstrip == line_content
    end

    line_number+1
  end
end
