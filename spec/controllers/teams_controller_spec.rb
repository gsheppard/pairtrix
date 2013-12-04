require 'spec_helper'

describe TeamsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:company) { FactoryGirl.create(:company, user: user) }
  let(:team) { FactoryGirl.create(:team, company: company) }
  let(:company_membership) { FactoryGirl.create(:company_membership, company: company, user: user) }

  def valid_attributes
    FactoryGirl.attributes_for(:team)
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
    it 'assigns all teams as @teams' do
      team.should be
      get :index, { company_id: company.to_param }, valid_session
      assigns(:teams).should eq([team])
    end
  end

  describe 'GET show' do
    it 'assigns the requested team as @team' do
      SecureRandom.should_receive(:uuid).and_return('uuid')
      get :show, { id: team.to_param }, valid_session
      assigns(:team).should eq(team)
      assigns(:uuid).should eq('uuid')
    end
  end

  describe 'GET new' do
    it 'assigns a new team as @team' do
      get :new, { company_id: company.to_param }, valid_session
      assigns(:team).should be_a_new(Team)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested team as @team' do
      team.should be
      get :edit, { id: team.to_param }, valid_session
      assigns(:team).should eq(team)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Team' do
        expect do
          post :create, { company_id: company.to_param, team: valid_attributes }, valid_session
        end.to change(Team, :count).by(1)
      end

      it 'assigns a newly created team as @team' do
        post :create, { company_id: company.to_param, team: valid_attributes }, valid_session
        assigns(:team).should be_a(Team)
        assigns(:team).should be_persisted
      end

      it 'redirects to the created team' do
        post :create, { company_id: company.to_param, team: valid_attributes }, valid_session
        response.should redirect_to(company_teams_url(company))
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved team as @team' do
        # Trigger the behavior that occurs when invalid params are submitted
        Team.any_instance.stub(:save).and_return(false)
        post :create, { company_id: company.to_param, team: { 'name' => '' } }, valid_session
        assigns(:team).should be_a_new(Team)
      end
    end
  end

  describe 'PUT update' do
    before do
      team.should be
    end

    describe 'with valid params' do
      it 'updates the requested team' do
        Team.any_instance.should_receive(:update_attributes).with({ 'name' => 'params' })
        put :update, { id: team.to_param, team: { 'name' => 'params' } }, valid_session
      end

      it 'assigns the requested team as @team' do
        put :update, { id: team.to_param, team: valid_attributes }, valid_session
        assigns(:team).should eq(team)
      end

      it 'redirects to the team' do
        put :update, { id: team.to_param, team: valid_attributes }, valid_session
        response.should redirect_to(company_teams_url(company))
      end
    end

    describe 'with invalid params' do
      it 'assigns the team as @team' do
        # Trigger the behavior that occurs when invalid params are submitted
        Team.any_instance.stub(:save).and_return(false)
        put :update, { id: team.to_param, team: { 'name' => '' } }, valid_session
        assigns(:team).should eq(team)
      end
    end
  end

  describe 'DELETE destroy' do
    before do
      team.should be
    end

    it 'destroys the requested team' do
      expect do
        delete :destroy, { id: team.to_param }, valid_session
      end.to change(Team, :count).by(-1)
    end

    it 'redirects to the teams list' do
      delete :destroy, { id: team.to_param }, valid_session
      response.should redirect_to(company_teams_url(company))
    end
  end
end
