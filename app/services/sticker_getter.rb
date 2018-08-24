# frozen_string_literal: true
QUERY_BASE = 'http://api.giphy.com/v1/gifs/search?q='
TRENDING_BASE = 'http://api.giphy.com/v1/gifs/trending?'
API_KEY = ENV['giphy_api_key']
SUFFIX = "&api_key=#{API_KEY}&limit=100&rating=pg-13"
PAGE_NUM = '&offset='
APP_ID = ENV['wechat_app_id']
APP_SECRET = ENV['wechat_app_secret']

class StickerGetter
  # Initial
  def initialize
    @cacher = Cacher.new
  end

  def get_query_stickers(parameters)
    # Retrieve Access token
    access_token = get_access_token


    # Check if query term is censored in China
    page_num = parameters[:page_num]
    query = parameters[:query]

    # if Chinese, do the following:
    # 1) the censor check,
    # 2) check for cached,
    # 3) encode for the URI,
    # 4) make the query with the right language param
    if query =~ /\p{Han}/
      puts "-=-=-=-=-=-=-=-=-"
      puts "This here is chaaaanese"
      lang = '&lang=zh-CN'


      # if passes censor check, check the language and change the lang param
      query = censor_check(access_token, query)



      # Combine query and page_num for accessing cache
      cache_key = "#{query}&#{page_num}"

      # Return cached results if sufficient
      cached_results = @cacher.get_stickers(cache_key)
      p "CACHED_RESULTS #{cached_results.size}, QUERY: #{cache_key}"
      return cached_results unless cached_results.empty?

      # Get results from giffy
      query = URI.encode(query)
      url = QUERY_BASE + query + SUFFIX + PAGE_NUM + page_num + lang

      options = {
        url: url,
        method: :get
      }

      raw_res = RestClient::Request.execute(options)
      res = JSON.parse(raw_res)
      stickers = res['data']

      # If no stickers match the query/page_num
      return false if stickers.empty?

      # Reject stickers that are too big
      filter_stickers!(stickers)

      # Add stickers to cache
      @cacher.add_stickers(key: cache_key, stickers: stickers)

      stickers

    else
      cache_key = "#{query}&#{page_num}"

      # Return cached results if sufficient
      cached_results = @cacher.get_stickers(cache_key)
      p "CACHED_RESULTS #{cached_results.size}, QUERY: #{cache_key}"
      return cached_results unless cached_results.empty?

      url = QUERY_BASE + query + SUFFIX + PAGE_NUM + page_num

      options = {
        url: url,
        method: :get
      }

      raw_res = RestClient::Request.execute(options)
      res = JSON.parse(raw_res)
      stickers = res['data']

      # If no stickers match the query/page_num
      return false if stickers.empty?

      # Reject stickers that are too big
      filter_stickers!(stickers)

      # Add stickers to cache
      @cacher.add_stickers(key: cache_key, stickers: stickers)

      stickers
    end
  end

  def get_trending_stickers(page_num)
    # Get cached stickers if they exist
    cached_results = @cacher.get_stickers("trending&#{page_num}")
    return cached_results unless cached_results.empty?

    # Get results from giffy
    url = TRENDING_BASE + SUFFIX + PAGE_NUM + page_num
    options = {
      url: url,
      method: :get
    }
    raw_res = RestClient::Request.execute(options)
    res = JSON.parse(raw_res)
    stickers = res['data']

    # Reject stickers that are too big
    filter_stickers!(stickers)

    # Add stickers to cache
    @cacher.add_stickers(key: "trending&#{page_num}", stickers: stickers)

    stickers
  end

  private

  def get_access_token
    puts 'Getting the access.. token...'

    # Return cached token if exists
    cached_token = @cacher.get_token
    return cached_token unless cached_token.empty?

    # Otherwise get new token from Tencent
    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{APP_ID}&secret=#{APP_SECRET}"
    puts url
    options = {
      url: url,
      method: :post
    }

    raw_res = RestClient::Request.execute(options)
    res = JSON.parse(raw_res)

    access_token = res['access_token']

    # Cache new token
    @cacher.set(key: 'cached_token', value: access_token)
    access_token
  end

  def censor_check(token, query)
    puts "Query #{query} ready for the censor check"

    # Check if query is already in cached list
    censored = @cacher.get_censored
    return 'panda' if censored.include?(query)

    # Call api
    params = { "content": query }.to_json

    raw_res = RestClient.post("https://api.weixin.qq.com/wxa/msg_sec_check?access_token=#{token}", params, content_type: 'application/json', accept: 'application/json')
    res = JSON.parse(raw_res)
    puts res

    if res['errcode'] == 0
      # search for sticker
      puts 'Okey dokey'
      return query

    elsif res['errcode'] == 87_014
      # render message
      puts 'pulling some pandas i guesss'

      # Add query to list of censored queries
      @cacher.add_censored(query)
      query = 'panda'
      return query

    elsif res['errcode'] == 44_001 || res['errorcode'] == 44_004
      # pull a random? load trending?
      puts 'possibly empty'
      return query

    elsif res['errcode'] == 42_001
      # IF token expired, clear cache, get a new one, try again
      @cacher.set(key: 'cached_token', value: '')
      token = get_access_token
      censor_check(token, query)
    end
  end

  def filter_stickers!(stickers)
    # Reject stickers larger than WeChat's limit
    stickers.reject! { |s| s['images']['original']['size'].to_i >= 400_000 }
  end
end
