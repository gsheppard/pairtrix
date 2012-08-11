require 'spec_helper'

describe EmployeesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:company) { FactoryGirl.create(:company, user: user) }
  let(:employee) { FactoryGirl.create(:employee, company: company) }

  def valid_attributes
    FactoryGirl.attributes_for(:employee)
  end

  def valid_session
    {}
  end

  def mock_user
    controller.stub(:current_user).and_return(user)
  end

  before do
    company.should be
  end

  describe "GET index" do
    it "assigns all employees as @employees" do
      employee.should be
      get :index, {company_id: company.to_param}, valid_session
      assigns(:employees).should eq([employee])
    end
  end

  describe "GET show" do
    it "assigns the requested employee as @employee" do
      get :show, {id: employee.to_param}, valid_session
      assigns(:employee).should eq(employee)
    end
  end

  describe "GET new" do
    it "assigns a new employee as @employee" do
      mock_user
      get :new, {company_id: company.to_param}, valid_session
      assigns(:employee).should be_a_new(Employee)
    end
  end

  describe "GET edit" do
    it "assigns the requested employee as @employee" do
      mock_user
      employee.should be
      get :edit, {id: employee.to_param}, valid_session
      assigns(:employee).should eq(employee)
    end
  end

  describe "POST create" do
    before do
      mock_user
    end

    describe "with valid params" do
      it "creates a new Employee" do
        expect {
          post :create, {company_id: company.to_param, employee: valid_attributes}, valid_session
        }.to change(Employee, :count).by(1)
      end

      it "assigns a newly created employee as @employee" do
        post :create, {company_id: company.to_param, employee: valid_attributes}, valid_session
        assigns(:employee).should be_a(Employee)
        assigns(:employee).should be_persisted
      end

      it "redirects to the created employee" do
        post :create, {company_id: company.to_param, employee: valid_attributes}, valid_session
        response.should redirect_to(company_employees_url(company))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved employee as @employee" do
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        post :create, {company_id: company.to_param, employee: {}}, valid_session
        assigns(:employee).should be_a_new(Employee)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        post :create, {company_id: company.to_param, employee: {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before do
      employee.should be
      mock_user
    end

    describe "with valid params" do
      it "updates the requested employee" do
        Employee.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {id: employee.to_param, employee: {'these' => 'params'}}, valid_session
      end

      it "assigns the requested employee as @employee" do
        put :update, {id: employee.to_param, employee: valid_attributes}, valid_session
        assigns(:employee).should eq(employee)
      end

      it "redirects to the employee" do
        put :update, {id: employee.to_param, employee: valid_attributes}, valid_session
        response.should redirect_to(company_employees_url(company))
      end
    end

    describe "with invalid params" do
      it "assigns the employee as @employee" do
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        put :update, {id: employee.to_param, employee: {}}, valid_session
        assigns(:employee).should eq(employee)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        put :update, {id: employee.to_param, employee: {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before do
      employee.should be
      mock_user
    end

    it "destroys the requested employee" do
      expect {
        delete :destroy, {id: employee.to_param}, valid_session
      }.to change(Employee, :count).by(-1)
    end

    it "redirects to the employees list" do
      delete :destroy, {id: employee.to_param}, valid_session
      response.should redirect_to(company_employees_url(company))
    end
  end
end
