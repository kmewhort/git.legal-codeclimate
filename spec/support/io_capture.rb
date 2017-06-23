# based on https://stackoverflow.com/questions/16507067/testing-stdout-output-in-rspec
require 'stringio'

def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end
