class StickersController < ApplicationController

  def get_stickers
    sg = StickerGetter.new()

    if params[:query]
      stickers = sg.get_query(query: params[:query], page_num: params[:page_num])
    else
      stickers = sg.get_trending(params[:page_num])
    end

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
