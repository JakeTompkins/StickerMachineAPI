class StickersController < ApplicationController
  def get_stickers
    # Initialize StickerGetter
    sg = StickerGetter.new()

    if params[:query]
      # Clean the query term of white space
      query = clean_query_input(params[:query])
      p "CLEANED: #{query}"
      # Get stickers either from cache or giffy
      @stickers = sg.get_query_stickers(query: query, page_num: params[:page_num])
    else
      # Get trending stickers from cache or giffy
      @stickers = sg.get_trending_stickers(params[:page_num])
    end

    if @stickers
      # Return stickers if there were any matches from giffy (including matches that don't pass filter)
      render :get_stickers
    else
      # Render error if no stickers match the search term
      render json: {
        error: "No stickers"
      }
    end
  end

  private

  def clean_query_input(query)
    # Clean the query term of whitespace and reformat for URL
    return query.downcase.scan(/\S+/).join("+")
  end
end
