class BoardController < ApplicationController
  def show
    @lists = List.all.includes(:cards)
  end
end
