require 'spec_helper'

describe PairsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:company) { FactoryGirl.create(:company, user: user) }
  let(:team) { FactoryGirl.create(:team, company: company) }
  let(:pairing_day) { FactoryGirl.create(:pairing_day, team: team) }
  let(:pair) { FactoryGirl.create(:pair_with_memberships, pairing_day: pairing_day) }
  let(:company_membership) { FactoryGirl.create(:company_membership, company: company, user: user) }

  def valid_attributes
    FactoryGirl.attributes_for(:pair)
  end

  def valid_session
    {}
  end

  def mock_user
    controller.stub(:current_user).and_return(user)
  end

  before do
    company_membership.should be
    mock_user
  end

  describe 'GET index' do
    it 'assigns all pairs as @pairs' do
      pair.should be
      get :index, { pairing_day_id: pairing_day.to_param, }, valid_session
      assigns(:pairs).should eq([pair])
    end
  end

  describe 'GET show' do
    it 'assigns the requested pair as @pair' do
      get :show, { id: pair.to_param }, valid_session
      assigns(:pair).should eq(pair)
    end
  end

  describe 'GET new' do
    it 'assigns a new pair as @pair' do
      get :new, { pairing_day_id: pairing_day.to_param, }, valid_session
      assigns(:pair).should be_a_new(Pair)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested pair as @pair' do
      get :edit, { id: pair.to_param }, valid_session
      assigns(:pair).should eq(pair)
    end
  end

  describe 'POST create' do
    let(:team_membership) { FactoryGirl.create(:team_membership, team: team) }
    let(:team_membership_1) { FactoryGirl.create(:team_membership, team: team) }

    describe 'with valid params' do
      before do
        pair_team_membership_string = [team_membership.id, team_membership_1.id].sort.join(',')
        Pusher.should_receive(:trigger).
          with("private-test-team-#{team.id}",
               'addPair',
               { pairMemberString: pair_team_membership_string,
                 pairId: kind_of(Numeric),
                 uuid: nil,
                 checksum: team.checksum }
              )
      end

      it 'creates a new Pair' do
        expect do
          post :create, { pairing_day_id: pairing_day.to_param, pair: { team_membership_ids: [team_membership.id, team_membership_1.id] } }, valid_session
        end.to change(Pair, :count).by(1)
        assigns(:pair).should be_persisted
        assigns(:pair).should be_a(Pair)
      end

      context 'with available team_memberships' do
        before do
          PairingDay.any_instance.should_receive(:available_team_memberships).and_return([double, double, double])
        end

        it 'redirects to create new pair' do
          post :create, { pairing_day_id: pairing_day.to_param, pair: valid_attributes.merge!(team_membership_ids: [team_membership.id, team_membership_1.id]) }, valid_session
          response.should redirect_to(new_pairing_day_pair_url(pairing_day))
        end
      end

      context 'without available team_memberships' do
        before do
          PairingDay.any_instance.should_receive(:available_team_memberships).and_return([double])
        end

        it 'redirects to pairing_day show page' do
          post :create, { pairing_day_id: pairing_day.to_param, pair: valid_attributes.merge!(team_membership_ids: [team_membership.id, team_membership_1.id]) }, valid_session
          response.should redirect_to(pairing_day_url(pairing_day))
        end
      end
    end

    describe 'with invalid params' do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Pair.any_instance.stub(:save).and_return(false)
      end

      it 'assigns a newly created but unsaved pair as @pair' do
        post :create, { pairing_day_id: pairing_day.to_param, pair: { 'team_membership_ids' => '' } }, valid_session
        assigns(:pair).should be_a_new(Pair)
        response.should render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested pair' do
        Pair.any_instance.should_receive(:update_attributes).with({ 'team_membership_ids' => ['1'] }).and_return(true)
        put :update, { id: pair.to_param, pair: { 'team_membership_ids' => [1] } }, valid_session
        assigns(:pair).should eq(pair)
        response.should redirect_to(pairing_day_url(pairing_day))
      end
    end

    describe 'with invalid params' do
      it 'assigns the pair as @pair' do
        # Trigger the behavior that occurs when invalid params are submitted
        Pair.any_instance.stub(:save).and_return(false)
        put :update, { id: pair.to_param, pair: { 'team_membership_ids' => '' } }, valid_session
        assigns(:pair).should eq(pair)
        response.should render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    before do
      pair_team_membership_string = pair.team_membership_ids.sort.join(',')
      Pusher.should_receive(:trigger).
        with("private-test-team-#{team.id}",
             'removePair',
             { pairMemberString: pair_team_membership_string,
               uuid: nil,
               checksum: team.checksum }
            )
    end

    it 'destroys the requested pair' do
      expect do
        delete :destroy, { id: pair.to_param }, valid_session
      end.to change(Pair, :count).by(-1)
    end

    it 'redirects to the pairs list' do
      delete :destroy, { id: pair.to_param }, valid_session
      response.should redirect_to(pairing_day_url(pairing_day))
    end
  end
end
