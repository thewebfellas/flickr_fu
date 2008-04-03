# wrapping class to hold a flickr size
# 
class Flickr::Auth::Token
  attr_accessor :token, :permisions, :user_id, :username, :user_real_name

  # create a new instance of a flickr auth token.
  # 
  # Params
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the token object
  def initialize(attributes)
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end

  # overide the default to_s to output the text of the token
  # 
  def to_s
    self.token.to_s
  end
end
