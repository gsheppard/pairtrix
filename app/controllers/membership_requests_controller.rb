class MembershipRequestsController < ApplicationController

  before_filter :authenticate_user!, only: :create

  skip_authorization_check except: :update

  load_and_authorize_resource :company
  load_and_authorize_resource through: :company, shallow: true
  permit_params :company_id, :user_id, :status

  skip_authorize_resource except: :update
  skip_authorize_resource :company, except: :update

  skip_load_resource only: [:approve, :deny]

  def create
    if !(membership_request = @company.membership_requests.where(user_id: current_user.id).first)
      membership_request = @company.membership_requests.create(user_id: current_user.id, status: 'Pending')
      MembershipRequestMailer.membership_request_email(membership_request).deliver
    end

    redirect_to root_url, flash: { warning: 'Membership Request creation succeeded.' }
  end

  def update
    case params[:commit]
    when 'Deny'
      params[:membership_request][:status] = 'Denied'
    when 'Approve'
      params[:membership_request][:status] = 'Approved'
      create_company_membership(@membership_request)
    end

    @membership_request.update_attributes(membership_request_params)
    email_membership_request_response(@membership_request)

    redirect_to company_url(@membership_request.company), flash: { warning: 'Membership Request updated.' }
  end

  def approve
    update_membership_request_from_hash_key(params[:id], 'Approved')
    redirect_to root_url, flash: { warning: 'Membership request updated.' }
  end

  def deny
    update_membership_request_from_hash_key(params[:id], 'Denied')
    redirect_to root_url, flash: { warning: 'Membership request updated.' }
  end

  private

  def update_membership_request_from_hash_key(key, status)
    if (membership_request = MembershipRequest.where(hash_key: key, status: 'Pending').first)
      membership_request.status = status
      membership_request.save
      create_company_membership(membership_request) if membership_request.approved?

      email_membership_request_response(membership_request)
    end
  end

  def create_company_membership(membership_request)
    membership_request.company.company_memberships.create(user_id: membership_request.user_id, role: 'member')
  end

  def email_membership_request_response(membership_request)
    MembershipRequestMailer.membership_request_response_email(membership_request).deliver
  end

  private

  def membership_request_params
    params.require(:membership_request).permit(:company_id, :user_id, :status)
  end
end
