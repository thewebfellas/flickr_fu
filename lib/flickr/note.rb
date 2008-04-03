# wrapping class to hold a flickr note
# 
class Flickr::Photos::Note
  attr_accessor :id, :note, :author, :author_name, :x, :y, :width, :height
  
  # create a new instance of a flickr note.
  # 
  # Params
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the note object
  def initialize(attributes)
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
end