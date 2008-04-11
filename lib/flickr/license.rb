class Flickr::Photos::License
  attr_accessor :id, :name, :url

  # create a new instance of a flickr photo license.
  # 
  # Params
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the license object
  def initialize(attributes)
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
end