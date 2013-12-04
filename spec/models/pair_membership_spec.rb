require 'spec_helper'

describe PairMembership do
  describe 'validations' do
    let(:pair_membership) { PairMembership.new }

    before do
      pair_membership.valid?
    end

    describe 'presence' do
      it 'validates the presence of pair' do
        pair_membership.should have(1).error_on(:pair)
      end

      it 'validates the presence of team_membership' do
        pair_membership.should have(1).error_on(:team_membership)
      end
    end
  end
end
