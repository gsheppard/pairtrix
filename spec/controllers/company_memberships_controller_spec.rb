require 'spec_helper'

describe CompanyMembershipsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:company) { FactoryGirl.create(:company, user: user) }
  let(:company_membership) { FactoryGirl.create(:company_membership, company: company, user: user) }
  let(:other_user) { FactoryGirl.create(:user) }

  def valid_attributes
    FactoryGirl.attributes_for(:company_membership).merge!({ user_id: other_user.id })
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
    it 'assigns all company_memberships as @company_memberships' do
      company_membership.should be
      get :index, { company_id: company.to_param }, valid_session
      assigns(:company_memberships).should eq([company_membership])
    end
  end

  describe 'GET show' do
    it 'assigns the requested company_membership as @company_membership' do
      get :show, { id: company_membership.to_param }, valid_session
      assigns(:company_membership).should eq(company_membership)
    end
  end

  describe 'GET new' do
    it 'assigns a new company_membership as @company_membership' do
      get :new, { company_id: company.to_param }, valid_session
      assigns(:company_membership).should be_a_new(CompanyMembership)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested company_membership as @company_membership' do
      company_membership.should be
      get :edit, { id: company_membership.to_param }, valid_session
      assigns(:company_membership).should eq(company_membership)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new CompanyMembership' do
        expect do
          post :create, { company_id: company.to_param, company_membership: valid_attributes }, valid_session
        end.to change(CompanyMembership, :count).by(1)
      end

      context 'with an existing MembershipRequest' do
        let!(:existing_membership_request) { FactoryGirl.create(:membership_request, user: other_user, company: company) }

        it "doesn't create a new MembershipRequest" do
          expect do
            post :create, { company_id: company.to_param, company_membership: valid_attributes }, valid_session
          end.to change(MembershipRequest, :count).by(0)
        end
      end

      context 'without an existing MembershipRequest' do
        it 'creates a new MembershipRequest' do
          expect do
            post :create, { company_id: company.to_param, company_membership: valid_attributes }, valid_session
          end.to change(MembershipRequest, :count).by(1)

          MembershipRequest.last.should be_approved
        end
      end

      it 'assigns a newly created company_membership as @company_membership' do
        post :create, { company_id: company.to_param, company_membership: valid_attributes }, valid_session
        assigns(:company_membership).should be_a(CompanyMembership)
        assigns(:company_membership).should be_persisted
      end

      it 'redirects to the created company_membership' do
        post :create, { company_id: company.to_param, company_membership: valid_attributes }, valid_session
        response.should redirect_to(company_company_memberships_url(company))
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved company_membership as @company_membership' do
        # Trigger the behavior that occurs when invalid params are submitted
        CompanyMembership.any_instance.stub(:save).and_return(false)
        post :create, { company_id: company.to_param, company_membership: { 'role' => '' } }, valid_session
        assigns(:company_membership).should be_a_new(CompanyMembership)
        response.should render_template('new')
      end
    end
  end

  describe 'PUT update' do
    before do
      company_membership.should be
    end

    describe 'with valid params' do
      it 'updates the requested company_membership' do
        CompanyMembership.any_instance.should_receive(:update_attributes).with({ 'company_id' => '1' }).and_return(true)
        put :update, { id: company_membership.to_param, company_membership: { 'company_id' => '1' } }, valid_session
        assigns(:company_membership).should eq(company_membership)
        response.should redirect_to(company_company_memberships_url(company))
      end
    end

    describe 'with invalid params' do
      it 'assigns the company_membership as @company_membership' do
        # Trigger the behavior that occurs when invalid params are submitted
        CompanyMembership.any_instance.stub(:save).and_return(false)
        put :update, { id: company_membership.to_param, company_membership: { 'role' => '' } }, valid_session
        assigns(:company_membership).should eq(company_membership)
        response.should render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    before do
      company_membership.should be
    end

    it 'destroys the requested company_membership' do
      expect do
        delete :destroy, { id: company_membership.to_param }, valid_session
      end.to change(CompanyMembership, :count).by(-1)
    end

    it 'redirects to the company_memberships list' do
      delete :destroy, { id: company_membership.to_param }, valid_session
      response.should redirect_to(company_company_memberships_url(company))
    end
  end
end
