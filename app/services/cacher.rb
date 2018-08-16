class Cacher
    def initialize()
        # Initialize Redis class
        @r = Redis.new(url: ENV["REDIS_URL"])
    end

    def set(parameters)
        # Create cache record
        @r.set(parameters[:key], parameters[:value])
        # Set expiration to 24 hours unless object is list of censored terms
        @r.expire(parameters[:key], 86400) unless parameters[:key] == "censored_queries"
    end

    def get_token
        # Return token stored in cache
        @r.get("cached_token") || ""
    end

    def get_stickers(key)
        # Get stickers stored in cache
        return [] if @r.get(key).nil?
        JSON.parse(@r.get(key))
    end

    def get_censored
        # Get list of censored terms
        return [] if @r.get("censored_queries").nil?
        JSON.parse(@r.get("censored_queries"))
    end

    def add_stickers(parameters)
        # Set variables
        query = parameters[:key]
        stickers = parameters[:stickers]

        p "ADD STICKERS #{stickers.size}"
        # Get current cached list (Should be empty array) 
        cached_stickers = get_stickers(query)

        p "CACHED_STICKERS #{cached_stickers.size}, QUERY: #{query}"
        # Add current array of stickers to cached array
        cached_stickers += stickers

        # Convert array to JSON
        cached_stickers = JSON.generate(cached_stickers)

        # Store JSON string in cache
        set(key:query, value: cached_stickers)
    end

    def add_censored(query)
        # Get already cached list of censored terms
        cached_censored = get_censored
        # Push query to the list
        cached_censored.push(query)
        # Convert array to JSON
        cached_censored = JSON.generate(cached_censored)
        # Store JSON back into cache
        set(key: "censored_queries", value: cached_censored)
    end
end
