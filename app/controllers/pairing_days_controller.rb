class PairingDaysController < ApplicationController

  load_and_authorize_resource :team
  load_and_authorize_resource :pairing_day, through: :team, shallow: true
  permit_params :team_id, :pairing_date

  def index
    @pairing_days = @team.pairing_days.order('pairing_date DESC')
  end

  def show
  end

  def new
    @pairing_day = @team.pairing_days.build(pairing_date: Date.current)
  end

  def edit
  end

  def create
    @pairing_day = @team.pairing_days.build(pairing_day_params)

    if @pairing_day.save
      redirect_to team_url(@pairing_day.team), flash: { success: 'Pairing Day was successfully created.' }
    else
      render action: 'new'
    end
  end

  def update
    if @pairing_day.update_attributes(pairing_day_params)
      redirect_to team_url(@pairing_day.team), flash: { success: 'Pairing Day was successfully updated.' }
    else
      render action: 'edit'
    end
  end

  def destroy
    @pairing_day.destroy
    redirect_to team_url(@pairing_day.team)
  end

  private

  def pairing_day_params
    params.require(:pairing_day).permit(:team_id, :pairing_date)
  end
end
