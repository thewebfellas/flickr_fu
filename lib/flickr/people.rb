class Flickr::People < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end
  
  # Get information about a user.
  # 
  # Params
  # * id (Required)
  #     the nsid of the user to get information for
  # 
  def find_by_id(id)
    rsp = @flickr.send_request('flickr.people.getInfo', {:user_id => id})
        
    Person.new(@flickr, :nsid => rsp.person[:nsid],
                        :is_admin => (rsp.person[:isadmin] == "1" ? true : false),
                        :is_pro => (rsp.person[:ispro] == "1" ? true : false),
                        :icon_server => rsp.person[:iconserver],
                        :icon_farm => rsp.person[:iconfarm],
                        :username => rsp.person.username.to_s,
                        :realname => rsp.person.realname.to_s,
                        :mbox_sha1sum => rsp.person.mbox_sha1sum.to_s,
                        :location => rsp.person.location.to_s,
                        :photos_url => rsp.person.photosurl.to_s,
                        :profile_url => rsp.person.profileurl.to_s,
                        :photo_count => rsp.person.photos.count.to_s.to_i,
                        :photo_first_upload => (Time.at(rsp.person.photos.firstdate.to_s.to_i) rescue nil),
                        :photo_first_taken => (Time.parse(rsp.person.photos.firstdatetaken.to_s) rescue nil))
  end
  
  # Get information about a user.
  # 
  # Params
  # * username (Required)
  #     the username of the user to get information for
  #
  def find_by_username(username)
    rsp = @flickr.send_request('flickr.people.findByUsername', {:username => username})
    
    find_by_id(rsp.user[:nsid])
  end
  
  # Get information about a user.
  # 
  # Params
  # * email (Required)
  #     the email of the user to get information for
  #
  def find_by_email(email)
    rsp = @flickr.send_request('flickr.people.findByEmail', {:find_email => email})
    
    find_by_id(rsp.user[:nsid])
  end
end