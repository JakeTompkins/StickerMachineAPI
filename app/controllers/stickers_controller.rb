class StickersController < ApplicationController
  before_action :authenticate_user, only: [:save_sticker, :get_user_stickers, :unfavorite]
  # respond_to :json

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

  def save_sticker
    sticker = Sticker.new(sticker_id: params[:sticker_id], url: params[:url], title: params[:title])
    puts "here's a user saving a sticker"
    puts current_user
    sticker.user = current_user
    sticker.save!
  end

  def get_user_stickers
    @user = current_user
    stickers = @user.stickers.order(created_at: :desc)
    render_data(stickers)
  end

  def unfavorite
    puts params[:sticker_id]
    @user = current_user
    @sticker = @user.stickers.find_by(sticker_id: params[:sticker_id])
    @sticker.destroy
  end

  private

  def clean_query_input(query)
    # Clean the query term of whitespace and reformat for URL
    return query.downcase.scan(/\S+/).join("+")
  end
end
