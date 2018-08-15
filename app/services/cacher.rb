class Cacher
    def initialize()
        @r = Redis.new(ENV["REDIS_URL"])
    end

    def set(parameters)
        # Convert value to array if hash
        if parameters[:value].is_a?(Hash)
            hash = parameters[:value]
            array = hash.to_a
        end
        @r.set(parameters[:key], array)
    end

    def get(key)
        @r.get(key)
    end

    def add(parameters)
        if parameters[:value].is_a?(Hash)
            hash = parameters[:value]
            array = hash.to_a
        end
        cached = (get(parameters[:key]) || [])
        cached += (array || parameters[:value])
        set(key: parameters[:key], value: cached)
    end
end
