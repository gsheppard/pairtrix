class PairsController < ApplicationController

  before_filter :load_pairing_day, only: [:index, :new, :create]

  load_and_authorize_resource :pairing_day
  load_and_authorize_resource :pair, through: :pairing_day, shallow: true
  permit_all_params

  def index
    @pairs = @pairing_day.pairs.to_a
  end

  def show
  end

  def new
    @pair = @pairing_day.pairs.build
  end

  def edit
  end

  def create
    @pair = @pairing_day.pairs.build(pair_params)

    if @pair.save
      save_pair_memberships
      Pusher.trigger(
        "private-#{Rails.env}-team-#{@pairing_day.team_id}",
        'addPair',
        { pairMemberString: pair_team_membership_string,
          pairId: @pair.id,
          uuid: params[:uuid],
          checksum: @pairing_day.team.checksum }
      )
      successful_create_response
    else
      failure_create_response
    end
  end

  def update
    if @pair.update_attributes(pair_params)
      redirect_to pairing_day_url(@pair.pairing_day), flash: { success: 'Pair was successfully updated.' }
    else
      render action: 'edit'
    end
  end

  def destroy
    @pair.destroy
    Pusher.trigger(
      "private-#{Rails.env}-team-#{@pair.pairing_day.team_id}",
      'removePair',
      { pairMemberString: pair_team_membership_string,
        uuid: params[:uuid],
        checksum: @pair.pairing_day.team.checksum }
    )
    respond_to do |format|
      format.html { redirect_to pairing_day_url(@pair.pairing_day) }
      format.json { render json: { success: true } }
    end
  end

  private

  def pair_team_membership_string
    @pair.team_membership_ids.sort.join(',')
  end

  def load_pairing_day
    if params[:pairing_day_id]
      @pairing_day = PairingDay.find(params[:pairing_day_id])
    elsif params[:team_id]
      find_or_create_pairing_day_for_team_id(params[:team_id])
    end
  end

  def find_or_create_pairing_day_for_team_id(team_id)
    team = Team.find(team_id)
    @pairing_day = team.pairing_days.where(pairing_date: Date.current).first ||
      team.pairing_days.create(pairing_date: Date.current)
  end

  def save_pair_memberships
    @pair.pair_memberships.each do |pair_membership|
      pair_membership.save!
    end
  end

  def successful_create_response
    respond_to do |format|
      format.html do
        redirect_url = @pairing_day.available_team_memberships? ? new_pairing_day_pair_url(@pairing_day) : pairing_day_url(@pairing_day)
        redirect_to redirect_url, flash: { success: 'Pair was successfully created.' }
      end

      format.json do
        render(json: { success: true, pairId: @pair.id })
      end
    end
  end

  def failure_create_response
    respond_to do |format|
      format.html do
        render action: 'new'
      end

      format.json do
        render(json: { success: false })
      end
    end
  end

  private

  def pair_params
    params.require(:pair).permit(team_membership_ids: [])
  end
end
