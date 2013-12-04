require 'spec_helper'

describe CompaniesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:company) { FactoryGirl.create(:company, user: user) }

  def valid_attributes
    FactoryGirl.attributes_for(:company)
  end

  def valid_session
    {}
  end

  def mock_user
    controller.stub(:current_user).and_return(user)
  end

  describe 'GET index' do
    it 'assigns all companies as @companies' do
      company.should be
      get :index, {}, valid_session
      expect(assigns(:companies)).to include(company)
    end
  end

  describe 'GET show' do
    it 'assigns the requested company as @company' do
      get :show, { id: company.to_param }, valid_session
      assigns(:company).should eq(company)
    end
  end

  describe 'GET new' do
    it 'assigns a new company as @company' do
      mock_user
      get :new, {}, valid_session
      assigns(:company).should be_a_new(Company)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested company as @company' do
      mock_user
      get :edit, { id: company.to_param }, valid_session
      assigns(:company).should eq(company)
    end
  end

  describe 'POST create' do
    before do
      mock_user
    end

    describe 'with valid params' do
      it 'creates a new Company' do
        expect do
          post :create, { company: valid_attributes }, valid_session
        end.to change(Company, :count).by(1)
      end

      it 'creates a new approved MembershipRequest' do
        expect do
          post :create, { company: valid_attributes }, valid_session
        end.to change(MembershipRequest, :count).by(1)

        MembershipRequest.last.should be_approved
      end

      it 'creates a new admin CompanyMembership' do
        expect do
          post :create, { company: valid_attributes }, valid_session
        end.to change(CompanyMembership, :count).by(1)

        CompanyMembership.last.should be_admin
      end

      it 'assigns a newly created company as @company' do
        post :create, { company: valid_attributes }, valid_session
        assigns(:company).should be_a(Company)
        assigns(:company).should be_persisted
      end

      it 'redirects to the created company' do
        post :create, { company: valid_attributes }, valid_session
        response.should redirect_to(companies_url)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved company as @company' do
        # Trigger the behavior that occurs when invalid params are submitted
        Company.any_instance.stub(:save).and_return(false)
        post :create, { company: { 'name' => '' } }, valid_session
        assigns(:company).should be_a_new(Company)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Company.any_instance.stub(:save).and_return(false)
        post :create, { company: { 'name' => '' } }, valid_session
        response.should render_template('new')
      end
    end
  end

  describe 'PUT update' do
    before do
      mock_user
    end

    describe 'with valid params' do
      it 'updates the requested company' do
        Company.any_instance.should_receive(:update_attributes).with({ 'name' => 'params' })
        put :update, { id: company.to_param, company: { 'name' => 'params' } }, valid_session
      end

      it 'assigns the requested company as @company' do
        put :update, { id: company.to_param, company: valid_attributes }, valid_session
        assigns(:company).should eq(company)
      end

      it 'redirects to the company' do
        put :update, { id: company.to_param, company: valid_attributes }, valid_session
        response.should redirect_to(companies_url)
      end
    end

    describe 'with invalid params' do
      it 'assigns the company as @company' do
        # Trigger the behavior that occurs when invalid params are submitted
        Company.any_instance.stub(:save).and_return(false)
        put :update, { id: company.to_param, company: { 'name' => '' } }, valid_session
        assigns(:company).should eq(company)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Company.any_instance.stub(:save).and_return(false)
        put :update, { id: company.to_param, company: { 'name' => '' } }, valid_session
        response.should render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    before do
      company.should be
      mock_user
    end

    it 'destroys the requested company' do
      expect do
        delete :destroy, { id: company.to_param }, valid_session
      end.to change(Company, :count).by(-1)
    end

    it 'redirects to the companies list' do
      delete :destroy, { id: company.to_param }, valid_session
      response.should redirect_to(companies_url)
    end
  end
end
