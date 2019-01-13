class ItemsController < ApplicationController
  def index
    render json: Item.first.item_modifiers.inspect
  end

  def create
    item = Item.new
    item.build_from_string(params[:item_string])
    item.save

    render json: item.inspect
  end
end
