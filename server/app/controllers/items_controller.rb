class ItemsController < ApplicationController
  def index
    render json: Item.first.item_modifiers.inspect
  end

  def create
    item = Item.new

    if item.save_from_string(params[:item_string])
      render json: 'Success'
    else
      render json: 'Failed to parse item', status: 400
    end
  end
end
