# wrapping class to hold a flickr size
# 
class Flickr::Photos::Size
  attr_accessor :label, :width, :height, :source, :url
  
  # create a new instance of a flickr size.
  # 
  # Params
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the size object
  def initialize(attributes)
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
end