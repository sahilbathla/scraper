class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index; end

  def scrape_data
    render json: ::Scrapper.new(params[:url]).call
  end
end
