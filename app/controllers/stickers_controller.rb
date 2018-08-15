class StickersController < ApplicationController

  def get_stickers
    sg = StickerGetter.new()

    if params[:query]
      query = clean_query_input(params[:query])
      p "CLEANED: #{query}"
      @stickers = sg.get_query_stickers(query: query, page_num: params[:page_num])
    else
      @stickers = sg.get_trending_stickers(params[:page_num])
    end

    if @stickers
      render :get_stickers
    else
      render json: {
        error: "No stickers"
      }
    end
  end

  private

  def clean_query_input(query)
    return query.downcase.scan(/[^\s]/).join("+")
  end
end
