# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class ExcerptExtension < Radiant::Extension
  version "0.1"
  description "Excerpt returns the first part of the enclosed content up to the specified length and makes sure to close any open html tags."
  url "http://yourwebsite.com/excerpt"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :excerpt
  #   end
  # end
  
  def activate
    Page.send :include, Excerpt
  end
  
  def deactivate
    # admin.tabs.remove "Excerpt"
  end
  
end
