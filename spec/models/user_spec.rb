require 'spec_helper'

describe User do
  describe '.from_omniauth' do
    let(:auth) { { 'provider' => 'google_oauth2', 'uid' => '1234' } }

    before do
      User.should_receive(:where).with(provider: auth['provider'], uid: auth['uid']).and_return([user])
    end

    context 'with an existing user' do
      let(:user) { double('user') }

      it 'returns the existing user' do
        User.from_omniauth(auth)
      end
    end

    context 'without an existing user' do
      let(:user) { nil }

      it 'should call create_with_omniauth' do
        User.should_receive(:create_with_omniauth).with(auth).and_return(true)
        User.from_omniauth(auth)
      end
    end
  end

  describe '.create_with_omniauth(auth)' do
    let(:auth) { { 'provider' => 'google_oauth2', 'uid' => '1234', 'info' => { 'name' => 'username', 'email' => 'user@comp.com' } } }
    let(:user) { double('user') }
    it 'should create the user' do
      user.should_receive(:provider=).with('google_oauth2')
      user.should_receive(:uid=).with('1234')
      user.should_receive(:name=).with('username')
      user.should_receive(:email=).with('user@comp.com')
      User.should_receive(:create!).and_yield(user)
      User.create_with_omniauth(auth)
    end
  end
end
