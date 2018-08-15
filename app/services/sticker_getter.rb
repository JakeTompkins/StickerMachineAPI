  QUERY_BASE = "http://api.giphy.com/v1/gifs/search?q="
  TRENDING_BASE = "http://api.giphy.com/v1/gifs/trending?"
  API_KEY = ENV["giphy_api_key"]
  SUFFIX = "&api_key=#{API_KEY}&limit=100&rating=pg-13"
  PAGE_NUM = "&offset="
  APP_ID = ENV["wechat_app_id"]
  APP_SECRET = ENV["wechat_app_secret"]

class StickerGetter
    def initialize()
      @cacher = Cacher.new()
    end
    
    def get_query_stickers(parameters)
        # Retrieve Access token
        access_token = get_access_token
        
        # Check if query term is censored in China
        query = parameters[:query]
        query = censor_check(access_token, query)

        # Return cached results if sufficient
        cached_results = @cacher.get_stickers(query)
        p "CACHED_RESULTS #{cached_results.size}, QUERY: #{query}"
        return cached_results if (cached_results && cached_results.size >= 10)

        url = QUERY_BASE + query + SUFFIX + PAGE_NUM + parameters[:page_num]

        options = {
            url: url,
            method: :get
          }
        
        raw_res = RestClient::Request.execute(options)
        res = JSON.parse(raw_res)
        stickers = res["data"]

        return false if stickers.empty?

        filter_stickers!(stickers)

        # Add stickers to cache
        @cacher.add_stickers(key: query, stickers: stickers)

        return stickers
    end

    def get_trending_stickers(page_num)
        cached_results = @cacher.get_stickers("trending")
        return cached_results unless (cached_results.empty? || cached_results.size < 10)
        
        url = TRENDING_BASE + SUFFIX + PAGE_NUM + page_num
        options = {
            url: url,
            method: :get
          }
        raw_res = RestClient::Request.execute(options)
        res = JSON.parse(raw_res)
        stickers = res["data"]

        filter_stickers!(stickers)

        # Add stickers to cache
        @cacher.add_stickers(key: "trending", stickers: stickers)

        return stickers
    end

    private

    def get_access_token
        puts "Getting the access.. token..."

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
    
        access_token = res["access_token"]

        # Cache new token
        @cacher.set(key: "cached_token", value: access_token)
        return access_token
      end

      def censor_check(token, query)
        puts "Query #{query} ready for the censor check"
        
        # Check if query is censored
        censored = @cacher.get_censored
        return "panda" if censored.include?(query)

        params = { "content": query }.to_json
    
        raw_res = RestClient.post("https://api.weixin.qq.com/wxa/msg_sec_check?access_token=#{token}", params, {content_type: 'application/json', accept: 'application/json'})
        res = JSON.parse(raw_res)
        puts res
    
        if res["errcode"] == 0
          # search for sticker
          puts "Okey dokey"
          return query

        elsif res["errcode"] == 87014
          # render message
          puts "pulling some pandas i guesss"
          
          # Add query to list of censored queries
          @cacher.add_censored(query)
          query = "panda"
          return query
    
        elsif res["errcode"] == 44001 || res["errorcode"] == 44004
          # pull a random? load trending?
            puts "possibly empty"
            return query
        end
      end

      def filter_stickers!(stickers)
        stickers.reject!{ |s| s["images"]["original"]["size"].to_i >= 400000 }
      end
end
