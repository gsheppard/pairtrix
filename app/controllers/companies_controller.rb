class CompaniesController < ApplicationController

  load_and_authorize_resource
  skip_authorize_resource only: [:index, :show]
  skip_authorization_check only: [:index, :show]
  permit_params :name, :user_id

  def index
    @companies = Company.all
  end

  def show
  end

  def new
    @company = current_user.companies.build
  end

  def edit
  end

  def create
    @company = current_user.companies.build(company_params)

    if @company.save
      @company.membership_requests.create(user_id: current_user.id, status: 'Approved')
      @company.company_memberships.create(user_id: current_user.id, role: 'admin')

      redirect_to companies_url, flash: { success: 'Company was successfully created.' }
    else
      render action: 'new'
    end
  end

  def update
    if @company.update_attributes(company_params)
      redirect_to companies_url, flash: { success: 'Company was successfully updated.' }
    else
      render action: 'edit'
    end
  end

  def destroy
    @company.destroy
    redirect_to companies_url
  end

  private

  def company_params
    params.require(:company).permit(:name, :user_id)
  end
end
