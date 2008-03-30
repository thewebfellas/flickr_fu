require 'rubygems'
require 'xml_magic'
require 'net/http'
require 'uri'
require 'digest/md5'

require File.join(File.dirname(__FILE__), 'flickr', 'base')
require File.join(File.dirname(__FILE__), 'flickr', 'auth')
require File.join(File.dirname(__FILE__), 'flickr', 'photos')

include CommonThread::XML

class Object
  # returning allows you to pass an object to a block that you can manipulate returning the manipulated object
  def returning(value)
    yield(value)
    value
  end
end