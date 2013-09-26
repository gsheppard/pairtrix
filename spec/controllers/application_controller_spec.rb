require 'spec_helper'

describe ApplicationController do

  describe "#user_signed_in?" do
    context "when there is a current user" do
      it "should be true" do
        user = double(:user)
        controller.stub(:current_user).and_return(user)
        controller.send(:user_signed_in?).should be_true
      end
    end

    context "when is not a current user" do
      it "should be false" do
        controller.stub(:current_user).and_return(nil)
        controller.send(:user_signed_in?).should be_false
      end
    end
  end

  describe "#admin?" do
    context "when there is a current user" do
      context "when the user is an admin?" do
        it "should be true" do
          user = double(:user, admin?: true)
          controller.stub(:current_user).and_return(user)
          controller.send(:admin?).should be_true
        end
      end

      context "when the user is not an admin?" do
        it "should be false" do
          user = double(:user, admin?: false)
          controller.stub(:current_user).and_return(user)
          controller.send(:admin?).should be_false
        end
      end
    end

    context "when is not a current user" do
      it "should be false" do
        controller.stub(:current_user).and_return(nil)
        controller.send(:admin?).should be_false
      end
    end
  end
end
