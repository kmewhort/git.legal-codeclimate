require 'open3'
class YarnParser
  def self.parse(file)
    raise 'NodeJS not found' unless system('which node')

    js_parser_exec = "#{File.dirname(__FILE__)}/yarn_parser/index.js"
    result, s = Open3.capture2("node #{js_parser_exec} #{file}")
    JSON.parse(result.force_encoding('UTF-8'))
  end
end
