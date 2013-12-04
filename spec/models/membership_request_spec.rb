require 'spec_helper'

describe MembershipRequest do
  describe 'validations' do
    let(:membership_request) { MembershipRequest.new }

    before do
      membership_request.valid?
    end

    describe 'presence' do
      it 'validates the presence of company_id' do
        membership_request.should have(1).error_on(:company_id)
      end

      it 'validates the presence of user_id' do
        membership_request.should have(1).error_on(:user_id)
      end

      it 'validates the presence of status' do
        membership_request.should have(1).error_on(:status)
      end
    end

    describe 'inclusion' do
      let(:membership_request) { MembershipRequest.new(status: status) }

      context 'with an invalid status' do
        let(:status) { 'Other' }

        it 'validates the presence of status' do
          membership_request.should have(1).error_on(:status)
        end
      end

      context 'with a valid status' do
        let(:status) { 'Approved' }

        it 'validates the presence of status' do
          membership_request.should have(0).errors_on(:status)
        end
      end
    end
  end

  describe '#approved?' do
    subject { membership_request.approved? }

    let(:membership_request) { MembershipRequest.new(status: status) }

    context 'as Approved' do
      let(:status) { 'Approved' }

      it { should be_true }
    end

    context 'as pending' do
      let(:status) { 'Pending' }

      it { should be_false }
    end
  end

  describe '#denied?' do
    subject { membership_request.denied? }

    let(:membership_request) { MembershipRequest.new(status: status) }

    context 'as Denied' do
      let(:status) { 'Denied' }

      it { should be_true }
    end

    context 'as pending' do
      let(:status) { 'Pending' }

      it { should be_false }
    end
  end

  describe '#pending?' do
    subject { membership_request.pending? }

    let(:membership_request) { MembershipRequest.new(status: status) }

    context 'as pending' do
      let(:status) { 'Pending' }

      it { should be_true }
    end

    context 'as Denied' do
      let(:status) { 'Denied' }

      it { should be_false }
    end
  end
end
