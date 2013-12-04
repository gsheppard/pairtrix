require 'spec_helper'

describe Team do

  describe 'callbacks' do
    describe '#after_commit' do
      it 'creates the default team memberships' do
        solo = FactoryGirl.create(:employee, last_name: 'Solo')
        company = solo.company
        FactoryGirl.create(:employee,
                           last_name: 'Office',
                           company: company
                          )
        team = FactoryGirl.build(:team, company: company)
        expect(team.team_memberships.size).to eq 0
        team.save!
        expect(team.team_memberships.size).to eq 2
      end
    end
  end

  describe 'validations' do
    let(:team) { Team.new }

    before do
      team.valid?
    end

    describe 'presence' do
      it 'validates the presence of name' do
        team.should have(1).error_on(:name)
      end
    end

    describe 'uniqueness' do
      let!(:existing_team) { FactoryGirl.create(:team) }

      context 'with a unique name' do
        before do
          team.name = 'xxy'
        end

        it 'validates the uniqueness of name' do
          team.should have(0).error_on(:name)
        end
      end

      context 'with a duplicate name' do
        before do
          team.name = existing_team.name
        end

        it 'validates the uniqueness of name' do
          team.should have(1).error_on(:name)
        end
      end
    end
  end

  describe 'checksum' do
    it 'returns a checksum of the employee ids' do
      team = Team.new
      employees = [
        double('employee', id: 4),
        double('employee', id: 2),
        double('employee', id: 1),
        double('employee', id: 3)
      ]
      team.stub(:employees).and_return(employees)

      team.checksum.should == '4001e76e5949268aa984e328877cbffd'
    end
  end
end
