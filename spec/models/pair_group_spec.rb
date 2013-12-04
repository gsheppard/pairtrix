require 'spec_helper'

describe PairGroup do
  let(:pair_group) { PairGroup.new(left_membership, top_membership) }

  describe '#do_not_pair?' do
    subject { pair_group.do_not_pair? }

    let(:left_employee) { FactoryGirl.build_stubbed(:employee, do_not_pair: do_not_pair_left) }
    let(:top_employee) { FactoryGirl.build_stubbed(:employee, do_not_pair: do_not_pair_top) }

    let(:left_membership) { FactoryGirl.build_stubbed(:team_membership, employee: left_employee) }
    let(:top_membership) { FactoryGirl.build_stubbed(:team_membership, employee: top_employee) }
    let(:do_not_pair_top) { false }
    let(:do_not_pair_left) { false }

    context 'when neither membership is do not pair' do
      it { should be_false }
    end

    context 'when only top membership is do not pair' do
      let(:do_not_pair_top) { true }

      it { should be_false }
    end

    context 'when only left membership is do not pair' do
      let(:do_not_pair_left) { true }

      it { should be_false }
    end

    context 'when both memberships are do not pair' do
      let(:do_not_pair_left) { true }
      let(:do_not_pair_top) { true }

      it { should be_true }
    end
  end

  describe '#team' do
    subject { pair_group.team }

    let(:left_membership) { FactoryGirl.build_stubbed(:team_membership) }
    let(:top_membership) { FactoryGirl.build_stubbed(:team_membership, team: left_membership.team) }

    it { should == left_membership.team }
  end

  describe '#ids' do
    subject { pair_group.ids }
    let(:top_membership) { double('top', id: top_id) }
    let(:left_membership) { double('left', id: left_id) }

    context 'with left membership id > top membership id' do
      let(:left_id) { 10 }
      let(:top_id) { 5 }

      it { should == "#{top_membership.id},#{left_membership.id}" }
    end

    context 'with top membership id > left membership id' do
      let(:left_id) { 5 }
      let(:top_id) { 10 }

      it { should == "#{left_membership.id},#{top_membership.id}" }
    end
  end

  describe '#current_pair?' do
    subject { pair_group.current_pair? }

    let!(:pairing_day) { FactoryGirl.create(:pairing_day, pairing_date: pairing_date) }
    let!(:pair) { FactoryGirl.create(:pair_with_memberships, pairing_day: pairing_day) }
    let(:left_membership) { pair.team_memberships[0] }
    let(:top_membership) { pair.team_memberships[1] }

    context 'when paired on the current pairing day' do
      let(:pairing_date) { Date.current }

      context 'with left membership first' do
        it { should be_true }
      end

      context 'with top membership first' do
        let(:top_membership) { pair.team_memberships[0] }
        let(:left_membership) { pair.team_memberships[1] }

        it { should be_true }
      end
    end

    context 'when not paired on the current pairing day' do
      let(:pairing_date) { Date.parse('12/31/1999') }

      it { should be_false }
    end
  end
end
