require 'rubygems'
require 'xml_magic'
require 'open-uri'
require 'digest/md5'
include CommonThread::XML

Dir[File.join(File.dirname(__FILE__), 'flickr/**/*.rb')].sort.each { |lib| require lib }

class Object
  # returning allows you to pass an object to a block that you can manipulate returning the manipulated object
  def returning(value)
    yield(value)
    value
  end
end