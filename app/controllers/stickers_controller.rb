class StickersController < ApplicationController
  BASE_URL = "http://api.giphy.com/v1/gifs/search?q="
  TRENDING_BASE = "http://api.giphy.com/v1/gifs/trending?"
  SUFFIX = "&api_key=#{ENV['api_key']}&limit=80&rating=pg-13"
  PAGE_NUM = "&offset="

  def get_stickers
    if params[:trending]
      url = TRENDING_BASE + SUFFIX + PAGE_NUM + params[:page_num]
    else
      url = BASE_URL + params[:query] + SUFFIX + PAGE_NUM + params[:page_num]
    end
    p "query #{params[:query]}"
    p "URL: #{url}"
    options = {
      url: url,
      method: :get
    }
    p "Beginning request"
    raw_res = RestClient::Request.execute(options)
    res = JSON.parse(raw_res)
    stickers = res["data"]
    p res
    if stickers.size >0
      stickers.reject!{ |s| s["images"]["original"]["size"].to_i >= 400000 }
      @stickers = stickers
      render :get_stickers
    else
      render json: {
        error: "No stickers"
      }
    end
  end
end