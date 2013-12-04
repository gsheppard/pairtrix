class User < ActiveRecord::Base

  LAST_VIEWED = 'last_viewed'
  DASHBOARD = 'dashboard'
  REDIRECT_OPTIONS = [DASHBOARD, LAST_VIEWED]

  has_many :companies
  has_many :membership_requests, dependent: :destroy
  has_many :company_memberships, dependent: :destroy

  class << self
    def from_omniauth(auth)
      where(provider: auth['provider'], uid: auth['uid']).first || create_with_omniauth(auth)
    end

    def create_with_omniauth(auth)
      create! do |user|
        user.provider = auth['provider']
        user.uid = auth['uid']
        user.name = auth['info']['name']
        user.email = auth['info']['email']
      end
    end
  end

  def available_teams
    Team.joins(company: :company_memberships).
      where('company_memberships.user_id = ?', id).
      order('companies.name ASC')
  end

  def save_last_viewed_url?
    sign_in_redirect_option == LAST_VIEWED
  end
end
