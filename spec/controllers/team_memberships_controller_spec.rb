require 'spec_helper'

describe TeamMembershipsController do
  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new TeamMembership' do
        user = FactoryGirl.create(:user)
        company = FactoryGirl.create(:company, user: user)
        team = FactoryGirl.create(:team, company: company)
        FactoryGirl.create(:company_membership, company: company, user: user)
        valid_attributes = FactoryGirl.attributes_for(:team_membership).merge!(employee_id: 1)
        controller.stub(:current_user).and_return(user)

        expect do
          post :create, { team_id: team.to_param, team_membership: valid_attributes, format: :json }
        end.to change(TeamMembership, :count).by(1)

        team_membership = assigns(:team_membership)
        expect(team_membership).to be_a(TeamMembership)
        expect(team_membership).to be_persisted
        expect(response.body).to eq team_membership.to_json
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested team_membership' do
      user = FactoryGirl.create(:user)
      company = FactoryGirl.create(:company, user: user)
      team = FactoryGirl.create(:team, company: company)
      FactoryGirl.create(:company_membership, company: company, user: user)
      team_membership = FactoryGirl.create(:team_membership, team: team)
      controller.stub(:current_user).and_return(user)

      expect do
        delete :destroy, { id: team_membership.to_param, format: :json }
      end.to change(TeamMembership, :count).by(-1)
      expect(response.body).to eq ''
    end
  end
end
