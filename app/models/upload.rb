class Upload < ActiveRecord::Base
  LIMIT = 20
  
  has_attached_file :avatar, 
    :url           => "/assets/:year/:month/:day/:basename_:style.:extension",
    :path          => ":rails_root/public/assets/:year/:month/:day/:basename_:style.:extension",
    :styles        => { :thumb => "120x120>", :tiny => "50x50>" },
    :default_url   => "/assets/missing:style.png",
    :default_style => :original
    
  named_scope :recents, :order => 'created_at DESC', :limit => LIMIT
end
