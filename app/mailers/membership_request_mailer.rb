class MembershipRequestMailer < ActionMailer::Base
  default from: 'noreply@pairtrix.com'

  def membership_request_email(membership_request)
    @user = membership_request.user
    @company = membership_request.company
    @hash_key = membership_request.hash_key
    mail(to: membership_request.company.user.email, subject: "[MEMBERSHIP REQUEST] for #{@company.name} from #{@user.name}")
  end

  def membership_request_response_email(membership_request)
    @user = membership_request.user
    @company = membership_request.company
    @status = membership_request.status
    mail(to: membership_request.user.email, subject: "[MEMBERSHIP #{@status.upcase}] to #{@company.name} for #{@user.name}")
  end
end
