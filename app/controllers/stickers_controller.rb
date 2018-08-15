class StickersController < ApplicationController
  BASE_URL = "http://api.giphy.com/v1/gifs/search?limit=100&q="
  TRENDING_BASE = "http://api.giphy.com/v1/gifs/trending?"
  API_KEY = ENV["giphy_api_key"]
  SUFFIX = "&api_key=#{API_KEY}&limit=80&rating=pg-13"
  PAGE_NUM = "&offset="
  APP_ID = ENV["wechat_app_id"]
  APP_SECRET = ENV["wechat_app_secret"]


  def get_access_token
    puts "Getting the access.. token..."


    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{APP_ID}&secret=#{APP_SECRET}"
    puts url
    options = {
      url: url,
      method: :post
    }

    raw_res = RestClient::Request.execute(options)
    res = JSON.parse(raw_res)

    access_token = res["access_token"]
    return access_token
  end

  def censor_check(token, query)
    puts "Query ready for the censor check"
    query.gsub!(' ', '+')
    params = { "content": query }.to_json

    raw_res = RestClient.post("https://api.weixin.qq.com/wxa/msg_sec_check?access_token=#{token}", params, {content_type: 'application/json', accept: 'application/json'})
    res = JSON.parse(raw_res)
    puts res

    if res["errcode"] == 0
      # search for sticker
      puts "Okey dokey"
      return query
      return
    elsif res["errcode"] == 87014
      # render message
      puts "pulling some pandas i guesss"
      query = "panda"
      return query

    elsif res["errcode"] == 44001 || 44004
      # pull a random? load trending?
        puts "possibly empty"
        return query
    end
  end

  def get_stickers
    if params[:trending]
      url = TRENDING_BASE + SUFFIX + PAGE_NUM + params[:page_num]
    else
      access_token = get_access_token
      print "ACCESS TOKEN #{access_token}"
      query = params[:query]
      query = censor_check(access_token, query)

      url = BASE_URL + query + SUFFIX + PAGE_NUM + params[:page_num]
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

    if stickers.size > 0
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
