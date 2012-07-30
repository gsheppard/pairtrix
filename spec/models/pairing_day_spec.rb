require 'spec_helper'

describe PairingDay do
  describe "validations" do
    subject { pairing_day }
    let(:pairing_day) { PairingDay.new }

    before do
      pairing_day.valid?
    end

    describe "presence" do
      describe "team_id" do
        it { should have(1).error_on(:team_id) }
      end

      describe "pairing_date" do
        it { should have(1).error_on(:pairing_date) }
      end
    end

    describe "uniqueness" do
      let!(:existing_pairing_day) { FactoryGirl.create(:pairing_day) }

      before do
        pairing_day.team_id = existing_pairing_day.team_id
      end

      context "with a unique pairing_date" do
        before do
          pairing_day.pairing_date = "1999-12-31"
        end

        it "validates the uniqueness of pairing_date" do
          pairing_day.should have(0).error_on(:pairing_date)
        end
      end

      context "with a duplicate pairing_date" do
        before do
          pairing_day.pairing_date = existing_pairing_day.pairing_date
        end

        it "validates the uniqueness of pairing_date" do
          pairing_day.should have(1).error_on(:pairing_date)
        end
      end
    end
  end

  describe "#to_param" do
    subject { pairing_day.to_param }
    let(:pairing_day) { FactoryGirl.create(:pairing_day, pairing_date: Date.parse("12/31/1999")) }

    it { should == "#{pairing_day.id}-1999-12-31" }
  end

  describe ".available_team_memberships" do
    subject { pairing_day.available_team_memberships }

    let!(:team) { FactoryGirl.create(:team) }
    let!(:pairing_day) { FactoryGirl.create(:pairing_day, team: team, pairing_date: pairing_date) }
    let(:pairing_date) { 5.days.ago }

    context "with no available team memberships" do
      it { should == [] }
    end

    context "with available team memberships" do
      let!(:available_team_membership) { FactoryGirl.create(:team_membership,
                                                            team: team,
                                                            start_date: pairing_date - 5.days) }
      let!(:unavailable_team_membership) { FactoryGirl.create(:team_membership,
                                                              team: team,
                                                              start_date: pairing_date - 5.days) }
      let!(:too_recent_team_membership) { FactoryGirl.create(:team_membership,
                                                             team: team) }
      let!(:other_team_membership) { FactoryGirl.create(:team_membership) }
      let!(:existing_pair) { FactoryGirl.create(:pair,
                                                team_membership_ids: unavailable_team_membership.id,
                                                pairing_day: pairing_day) }

      it { should include(available_team_membership) }
      it { should_not include(unavailable_team_membership) }
      it { should_not include(other_team_membership) }
      it { should_not include(too_recent_team_membership) }
    end
  end
end
