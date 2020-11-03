class CardsController < ApplicationController
  before_action :set_card, only: [:update, :destroy]

  # POST /cards.json
  # create or update name
  def create
    sleep 0.3
    @card = Card.find_or_initialize_by(id: params[:id])

    if @card.update(card_params)
      render :show, status: :created, location: @card
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  # PUT /cards/1.json
  # move to another list
  def update
    sleep 0.3

    @card.update(card_params)
    render json: { status: 'OK' }, status: :ok
  end

  # DELETE /cards/1
  # DELETE /cards/1.json
  def destroy
    @card.destroy
    respond_to do |format|
      format.html { redirect_to cards_url, notice: 'Card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def card_params
      params.require(:card).permit(:list_id, :name, :order)
    end
end
