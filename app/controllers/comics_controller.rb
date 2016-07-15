class ComicsController < ApplicationController
  def index
    @comics = Comic.all
    respond_to do |x|
      x.json {render json: @comics}
      x.html
    end

  end
end
