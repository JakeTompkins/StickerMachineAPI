json.pagination do
    json.total_count @stickers.size
end
json.data do

    json.array! @stickers do |sticker|
        json.url sticker["images"]["original"]["url"]
    end
end
