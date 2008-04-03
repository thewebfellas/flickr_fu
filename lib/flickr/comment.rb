# wrapping class to hold a flickr comment
# 
class Flickr::Photos::Comment
  attr_accessor :id, :comment, :author, :author_name, :created_at, :permalink
  
  # create a new instance of a flickr comment.
  # 
  # Params
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the comment object
  def initialize(attributes)
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
end