require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    controller.stub(:authenticate_user!).and_return(true)
    controller.stub(:current_user).and_return(user)
  end

  describe "GET 'dashboard'" do
    it 'returns http success' do
      get 'dashboard'
      response.should be_success
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the current_user' do
        User.any_instance.should_receive(:update_attributes).with({ 'these' => 'params' })
        put :update, { id: user.to_param, user: { 'these' => 'params' }, format: 'json' }
        response.body.should == ''
      end
    end
  end
end
