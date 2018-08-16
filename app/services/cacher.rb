class Cacher
    def initialize()
        @r = Redis.new(url: ENV["REDIS_URL"])
    end

    def set(parameters)
        @r.set(parameters[:key], parameters[:value])
        @r.expire(parameters[:key], 86400) unless parameters[:key] == "censored_queries"
    end

    def get_token
        @r.get("cached_token")
    end

    def get_stickers(key)
        return [] if @r.get(key).nil?
        JSON.parse(@r.get(key))
    end

    def get_censored
        return [] if @r.get("censored_queries").nil?
        JSON.parse(@r.get("censored_queries"))
    end

    def add_stickers(parameters)
        query = parameters[:key]
        stickers = parameters[:stickers]

        p "ADD STICKERS #{stickers.size}"

        cached_stickers = get_stickers(query)

        p "CACHED_STICKERS #{cached_stickers.size}, QUERY: #{query}"
        cached_stickers += stickers

        cached_stickers = JSON.generate(cached_stickers)

        set(key:query, value: cached_stickers)
    end

    def add_censored(query)
        cached_censored = get_censored
        cached_censored.push(query)

        cached_censored = JSON.generate(cached_censored)

        set(key: "censored_queries", value: cached_censored)
    end
end
