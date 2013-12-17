# -*- encoding : utf-8 -*-
Rails.application.routes.draw do
  
  #=== Search Routing
  get   "/suche/:query(/:only)",      :controller => "search", :action => "all"
  post  "/suche/:query(/:only)",      :controller => "search", :action => "all"
  post  "/suche",                     :controller => "search", :action => "all"

end
