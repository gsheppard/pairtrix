require 'spec_helper'

describe CompanyMembership do
  describe "validations" do
    let(:company_membership) { CompanyMembership.new }

    before do
      company_membership.valid?
    end

    describe "presence" do
      it "validates the presence of company_id" do
        company_membership.should have(1).error_on(:company_id)
      end

      it "validates the presence of user_id" do
        company_membership.should have(1).error_on(:user_id)
      end

      it "validates the presence of role" do
        company_membership.should have(1).error_on(:role)
      end
    end

    describe "inclusion" do
      let(:company_membership) { CompanyMembership.new(role: role) }

      context "with an invalid role" do
        let(:role) { "Other" }

        it "validates the presence of role" do
          company_membership.should have(1).error_on(:role)
        end
      end

      context "with a valid role" do
        let(:role) { "admin" }

        it "validates the presence of role" do
          company_membership.should have(0).errors_on(:role)
        end
      end
    end
  end
end