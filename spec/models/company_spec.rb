require 'spec_helper'

describe Company do
  describe 'callbacks' do
    describe '#after_commit' do
      it 'creates the default employees' do
        company = FactoryGirl.build(:company)
        expect(company.employees.size).to eq 0
        company.save!
        expect(company.employees.size).to eq 2
      end
    end
  end

  describe 'validations' do
    let(:company) { Company.new }

    before do
      company.valid?
    end

    describe 'presence' do
      it 'validates the presence of name' do
        company.should have(1).error_on(:name)
      end
    end

    describe 'uniqueness' do
      let!(:existing_company) { FactoryGirl.create(:company) }

      before do
        company.user_id = existing_company.user_id
      end

      context 'with a unique name' do
        before do
          company.name = 'fakename'
        end

        it 'validates the uniqueness of name' do
          company.should have(0).error_on(:name)
        end
      end

      context 'with a duplicate name' do
        before do
          company.name = existing_company.name
        end

        it 'validates the uniqueness of name' do
          company.should have(1).error_on(:name)
        end
      end
    end
  end

  describe '#has_membership_for?' do
    subject { company.has_membership_for?(user) }

    let(:membership_user) { FactoryGirl.create(:user) }
    let(:company_membership) { FactoryGirl.create(:company_membership, user: membership_user) }
    let(:company) { company_membership.company }

    before do
      company.should be
    end

    context 'when it has a membership' do
      let(:user) { membership_user }

      it { should be_true }
    end

    context "when it doesn't have a membership" do
      let(:user) { FactoryGirl.create(:user) }

      it { should be_false }
    end
  end

  describe '#available_users' do
    context 'with no available users' do
      it 'returns no users' do
        User.destroy_all
        company = FactoryGirl.create(:company)
        user = company.user
        FactoryGirl.create(:company_membership,
                           company: company,
                           user: user)
        company.available_users.should == []
      end
    end

    context 'with available users' do
      it 'returns the correct users' do
        company = FactoryGirl.create(:company)
        user = company.user
        FactoryGirl.create(:company_membership,
                           company: company,
                           user: user)
        available_user_unpersisted_membership = FactoryGirl.create(:user)
        available_user = FactoryGirl.create(:user)
        company.company_memberships.build(user_id: available_user_unpersisted_membership.id)

        company.available_users.should include(available_user)
        company.available_users.should include(available_user_unpersisted_membership)
        company.available_users.should_not include(user)
      end
    end
  end

  describe '#available_employees' do
    subject { company.available_employees }

    let!(:company) { FactoryGirl.create(:company) }
    let!(:employee) { FactoryGirl.create(:employee, company: company) }
    let!(:other_employee) { FactoryGirl.create(:employee, company: company) }

    let!(:team) { FactoryGirl.create(:team, company: company) }

    let!(:team_membership) { FactoryGirl.create(:team_membership, team: team, employee: employee) }
    let!(:other_team_membership) { FactoryGirl.create(:team_membership, team: team, employee: other_employee) }

    context 'with no available employees' do
      it { should == [] }

      context 'and a current active membership' do
        it { should_not include(employee) }
        it { should_not include(other_employee) }
      end
    end

    context 'with available employees' do
      context 'when the employee has no memberships' do
        let!(:no_membership_employee) { FactoryGirl.create(:employee, company: company) }

        it { should include(no_membership_employee) }
        it { should_not include(employee) }
        it { should_not include(other_employee) }
      end
    end
  end
end
