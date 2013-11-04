require 'spec_helper'

describe PairingDaysController do
  let(:user) { FactoryGirl.create(:user) }
  let(:company) { FactoryGirl.create(:company, user: user) }
  let(:team) { FactoryGirl.create(:team, company: company) }
  let(:pairing_day) { FactoryGirl.create(:pairing_day, team: team) }
  let(:company_membership) { FactoryGirl.create(:company_membership, company: company, user: user) }

  def valid_attributes
    FactoryGirl.attributes_for(:pairing_day)
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

  describe "GET index" do
    it "assigns all pairing_days as @pairing_days" do
      pairing_day.should be
      get :index, { team_id: team.to_param, }, valid_session
      assigns(:pairing_days).should eq([pairing_day])
    end
  end

  describe "GET show" do
    it "assigns the requested pairing_day as @pairing_day" do
      get :show, { id: pairing_day.to_param }, valid_session
      assigns(:pairing_day).should eq(pairing_day)
    end
  end

  describe "GET new" do
    it "assigns a new pairing_day as @pairing_day" do
      get :new, { team_id: team.to_param, }, valid_session
      assigns(:pairing_day).should be_a_new(PairingDay)
    end
  end

  describe "GET edit" do
    it "assigns the requested pairing_day as @pairing_day" do
      get :edit, { id: pairing_day.to_param }, valid_session
      assigns(:pairing_day).should eq(pairing_day)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PairingDay" do
        expect {
          post :create, { team_id: team.to_param, pairing_day: valid_attributes }, valid_session
        }.to change(PairingDay, :count).by(1)
      end

      it "assigns a newly created pairing_day as @pairing_day" do
        post :create, { team_id: team.to_param, pairing_day: valid_attributes }, valid_session
        assigns(:pairing_day).should be_an(PairingDay)
        assigns(:pairing_day).should be_persisted
      end

      context "without available team_memberships" do
        it "redirects to team show page" do
          post :create, { team_id: team.to_param, pairing_day: valid_attributes }, valid_session
          response.should redirect_to(team_url(team))
        end
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        PairingDay.any_instance.stub(:save).and_return(false)
      end

      it "assigns a newly created but unsaved pairing_day as @pairing_day" do
        post :create, { team_id: team.to_param, pairing_day: {'team_id' => ''} }, valid_session
        assigns(:pairing_day).should be_a_new(PairingDay)
      end

      it "re-renders the 'new' template" do
        post :create, { team_id: team.to_param, pairing_day: {'team_id' => ''} }, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested pairing_day" do
        PairingDay.any_instance.should_receive(:update_attributes).with({'team_id' => 'params'})
        put :update, { id: pairing_day.to_param, pairing_day: {'team_id' => 'params'} }, valid_session
      end

      it "assigns the requested pairing_day as @pairing_day" do
        put :update, { id: pairing_day.to_param, pairing_day: valid_attributes }, valid_session
        assigns(:pairing_day).should eq(pairing_day)
      end

      it "redirects to the pairing_day" do
        put :update, { id: pairing_day.to_param, pairing_day: valid_attributes }, valid_session
        response.should redirect_to(team_url(team))
      end
    end

    describe "with invalid params" do
      it "assigns the pairing_day as @pairing_day" do
        # Trigger the behavior that occurs when invalid params are submitted
        PairingDay.any_instance.stub(:save).and_return(false)
        put :update, { id: pairing_day.to_param, pairing_day: {'team_id' => team.id} }, valid_session
        assigns(:pairing_day).should eq(pairing_day)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        PairingDay.any_instance.stub(:save).and_return(false)
        put :update, { id: pairing_day.to_param, pairing_day: {'team_id' => team.id} }, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before do
      pairing_day.should be
    end

    it "destroys the requested pairing_day" do
      expect {
        delete :destroy, { id: pairing_day.to_param }, valid_session
      }.to change(PairingDay, :count).by(-1)
    end

    it "redirects to the pairing_days list" do
      delete :destroy, { id: pairing_day.to_param }, valid_session
      response.should redirect_to(team_url(team))
    end
  end
end
