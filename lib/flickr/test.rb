class Flickr::Test
  def initialize(flickr)
    @flickr = flickr
  end
  
  # A testing method which checks if the caller is logged in then returns their username.
  # 
  def login
    rsp = @flickr.send_request('flickr.test.login')
    rsp.user.username.to_s
  end
  
  # A testing method which echo's all parameters back in the response.
  # 
  # pass any number of options as a hash and it will be returned
  # 
  def echo(options = {})
    rsp = @flickr.send_request('flickr.test.echo', options)
    
    options
  end
  
  # Null test
  # 
  # Returns true unless there is an error
  # 
  def null
     rsp = @flickr.send_request('flickr.test.null')
     true
  end
end