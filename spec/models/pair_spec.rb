require 'spec_helper'

describe Pair do
  describe 'validations' do
    subject { pair }
    let(:pair) { Pair.new }

    before do
      pair.valid?
    end

    describe 'presence' do
      describe 'pairing_day'
      it { should have(1).error_on(:pairing_day) }
    end

    describe 'pair membership count' do
      context 'with two members' do
        let(:pair) { FactoryGirl.build(:pair_with_memberships) }

        it { should have(0).errors_on(:base) }
      end

      context 'with less than two members' do
        it { should have(1).error_on(:base) }
      end

    end
  end

  describe '#name' do
    let(:pair) { FactoryGirl.create(:pair_with_memberships) }

    it 'returns the team_membership names joined by dashes' do
      pair.name.should include(pair.pair_memberships[0].name)
      pair.name.should include(pair.pair_memberships[1].name)
    end
  end

  describe '#employee_one' do
    subject { pair.employee_one }
    let(:pair) { FactoryGirl.create(:pair_with_memberships) }

    it { should == pair.pair_memberships[0].name }
  end

  describe '#employee_two' do
    subject { pair.employee_two }
    let(:pair) { FactoryGirl.create(:pair_with_memberships) }

    it { should == pair.pair_memberships[1].name }
  end

  describe '#has_membership?' do
    subject { pair.has_membership?(membership) }

    let!(:pair) { FactoryGirl.create(:pair_with_memberships) }
    let(:membership_one) { pair.team_memberships[0] }
    let(:membership_two) { pair.team_memberships[1] }

    context 'when the pair has the membership' do
      let(:membership) { membership_one }
      it { should be_true }
    end

    context "when the pair doesn't have the membership" do
      let(:membership) { FactoryGirl.create(:team_membership) }
      it { should be_false }
    end
  end

  describe '#other_membership' do
    subject { pair.other_membership(membership) }

    let!(:pair) { FactoryGirl.create(:pair_with_memberships) }
    let(:membership_one) { pair.team_memberships[0] }
    let(:membership_two) { pair.team_memberships[1] }

    context 'when membership is the first one' do
      let(:membership) { membership_one }
      it { should == membership_two }
    end

    context 'when membership is the second one' do
      let(:membership) { membership_two }
      it { should == membership_one }
    end
  end
end
