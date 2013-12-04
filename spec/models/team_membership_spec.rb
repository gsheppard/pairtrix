require 'spec_helper'

describe TeamMembership do
  describe 'validations' do
    let(:team_membership) { TeamMembership.new }

    before { team_membership.valid? }

    describe 'presence' do
      it 'validates the presence of team_id' do
        team_membership.should have(1).error_on(:team_id)
      end

      it 'validates the presence of employee_id' do
        team_membership.should have(1).error_on(:employee_id)
      end
    end

    describe 'uniqueness' do
      let!(:existing_team_membership) { FactoryGirl.create(:team_membership) }

      context 'with a unique employee_id' do
        before { team_membership.employee_id = 999999 }

        it 'validates the uniqueness of employee_id' do
          team_membership.should have(0).error_on(:employee_id)
        end
      end

      context 'with a duplicate employee_id' do
        before { team_membership.employee_id = existing_team_membership.employee_id }

        it 'validates the uniqueness of employee_id' do
          team_membership.should have(1).error_on(:employee_id)
        end
      end
    end
  end

  describe 'deleteing a team membership' do
    it 'deletes all the pair memberships and pairs associated with the employee' do
      @pair = FactoryGirl.create(:pair_with_memberships)
      @team_membership = @pair.team_memberships.first
      expect { @team_membership.destroy }.to change { Pair.count }.by(-1)
    end
  end
end
