require 'mechanize'
class ComicsController < ApplicationController
  def index
    @comics = Comic.all
    respond_to do |x|
      x.json {render json: @comics}
      x.html
    end
  end
  def search
  	agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  	elastic_map = ENV['ELASTIC_MAP']
	elastic_search_url = ENV['ELASTIC_SEARCH']
  	value = agent.post("#{elastic_search_url}#{elastic_map}_search", {"query"=>{"match"=>{"series"=>{"query"=>"#{search_params["query"]}","fuzziness"=>"AUTO"}}}}.to_json, {'Content-Type' => 'application/json'})
  	render json: value.to_json
  end

  private
  def search_params
  	params.permit(:query)
  end
end
