require 'virtus'

class MicroService
  include Virtus.model

  def self.call(*args, &block)
    if block_given?
      new(*args).call(&block)
    else
      new(*args).call
    end
  end
end

