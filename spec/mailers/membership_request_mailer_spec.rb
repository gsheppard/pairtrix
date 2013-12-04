require 'spec_helper'

describe MembershipRequestMailer do
  describe '#membership_request_email' do

    let(:user) { FactoryGirl.create(:user) }
    let(:company) { FactoryGirl.create(:company, user: user) }
    let(:membership_request) { FactoryGirl.create(:membership_request, user: user, company: company) }

    let(:mail) { MembershipRequestMailer.membership_request_email(membership_request) }

    # ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should =~ /^\[MEMBERSHIP REQUEST\]/
    end

    # ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    # ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['noreply@pairtrix.com']
    end

    # ensure that the @name variable appears in the email body
    it 'assigns @user' do
      mail.body.encoded.should match(user.name)
    end

    # ensure that the @company variable appears in the email body
    it 'assigns @company' do
      mail.body.encoded.should match(company.name)
    end

    # ensure that the @hash_key variable appears in the email body
    it 'assigns @hash_key' do
      mail.body.encoded.should match(membership_request.hash_key)
    end
  end

  describe '#membership_request_response_email' do
    let(:user) { FactoryGirl.create(:user) }
    let(:requesting_user) { FactoryGirl.create(:user) }
    let(:company) { FactoryGirl.create(:company, user: user) }
    let(:membership_request) { FactoryGirl.create(:membership_request, user: requesting_user, company: company, status: status) }
    let(:status) { 'Approved' }

    let(:mail) { MembershipRequestMailer.membership_request_response_email(membership_request) }

    context 'when approved' do
      it 'renders the subject' do
        mail.subject.should =~ /^\[MEMBERSHIP APPROVED\]/
      end
    end

    context 'when denied' do
      let(:status) { 'Denied' }

      it 'renders the subject' do
        mail.subject.should =~ /^\[MEMBERSHIP DENIED\]/
      end
    end

    # ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == [requesting_user.email]
    end

    # ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['noreply@pairtrix.com']
    end

    # ensure that the @name variable appears in the email body
    it 'assigns @user' do
      mail.body.encoded.should match(requesting_user.name)
    end

    # ensure that the @company variable appears in the email body
    it 'assigns @company' do
      mail.body.encoded.should match(company.name)
    end

    # ensure that the @company variable appears in the email body
    it 'assigns @status' do
      mail.body.encoded.should match('Approved')
    end
  end
end
