require 'spec_helper'

describe PairMatrixCalculator do

  describe '#complete_pair_hash' do
    subject { calculator.complete_pair_hash }
    let(:calculator) { PairMatrixCalculator.new(pairs, memberships) }

    context 'with no memberships' do
      let(:pairs) { [] }
      let(:memberships) { [] }

      it { should == {} }
    end

    context 'with memberships' do
      let!(:pair) { FactoryGirl.create(:pair_with_memberships) }
      let(:pairs) { [pair] }
      let(:memberships) { pair.team_memberships }
      let(:membership_one) { pair.team_memberships[0] }
      let(:membership_two) { pair.team_memberships[1] }

      context 'with no extra memberships' do
        it { should == { membership_one.employee_id => { membership_two.employee_id => 1 }, membership_two.employee_id => { membership_one.employee_id => 1 } } }
      end

      context 'with extra memberships' do
        let(:team) { pair.pairing_day.team }
        let!(:membership_three) { FactoryGirl.create(:team_membership, team: team) }
        let(:memberships) { [membership_one, membership_two, membership_three] }

        it { should == { membership_three.employee_id => {}, membership_one.employee_id => { membership_two.employee_id => 1 }, membership_two.employee_id => { membership_one.employee_id => 1 } } }
      end
    end
  end
end
