require 'spec_helper'

describe SessionsController do

  describe 'create' do

    before do
      user = mock_model(User)
      User.should_receive(:from_omniauth).and_return(user)
      user.stub(:save_last_viewed_url?).and_return(save_url?)
      user.stub(:last_viewed_url).and_return(saved_url)

      post 'create'
      session[:user_id].should == user.id
      flash[:success].should =~ /Signed in/i
    end

    context 'when saving last viewed url' do
      let(:save_url?) { true }

      context 'with a saved url' do
        let(:saved_url) { 'http://site.com/example' }

        it 'redirects to the dashboard' do
          response.should redirect_to(saved_url)
        end
      end

      context 'with an empty url' do
        let(:saved_url) { '' }

        it 'redirects to the dashboard' do
          response.should redirect_to(dashboard_url)
        end
      end
    end

    context 'when not saving last viewed url' do
      let(:save_url?) { false }
      let(:saved_url) { '' }

      it 'redirects to the dashboard' do
        response.should redirect_to(dashboard_url)
      end
    end
  end

  describe 'destroy' do
    it 'should redirect to root' do
      post 'destroy'
      session[:user_id].should be_nil
      flash[:notice].should =~ /Signed out/i
      response.should redirect_to(root_url)
    end
  end

  describe 'failure' do
    it 'should redirect to root' do
      post 'failure'
      flash[:error].should =~ /failed/i
      response.should redirect_to(root_url)
    end
  end
end
