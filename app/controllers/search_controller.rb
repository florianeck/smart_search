# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  
  def all
    
    if params[:search]
      @query = params[:search][:query]
    else
      @query = params[:query]  
    end  

    unless @query.blank?
      team = current_user.get_team_tree(:get_ids => true )
      @results = []
      SmartSearch::Config.get_search_models.each do |m|
        if params[:only].nil? || params[:only] == m.to_s.split("::").last 
          # Filter das nur vorhandene Dokumente angezeigt werden
          if m.name.match("Document")
            @results << m.find_by_tags(@query).select {|f| puts "checking #{f.path}"; File.exists?(f.path) }
          else  
            @results << m.find_by_tags(@query)
          end  
        end  
      end  
    
      @empty = @results.flatten.empty?
    
      if request.xhr?
        render :partial => "/search/results_small", :locals => {:results => @results, :no_limit => !params[:only].nil?}, :layout => params[:layout]
      end
    else
      render :text => "Bitte geben Sie einen Suchbegriff ein"    
    end  
    
  end  
  
end



# (admin? || backoffice? || controller? || backoffice_vertrieb?) ||
