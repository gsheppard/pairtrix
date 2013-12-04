class CompanyMembership < ActiveRecord::Base

  ROLES = ['admin', 'member']

  belongs_to :company
  belongs_to :user

  validates_presence_of :company_id
  validates_presence_of :user_id
  validates_presence_of :role

  validates_uniqueness_of :user_id, scope: :company_id

  validates_inclusion_of :role, in: CompanyMembership::ROLES, if: :role

  class << self
    def member
      where(role: 'member')
    end

    def admin
      where(role: 'admin')
    end
  end

  def admin?
    role == 'admin'
  end

  def member?
    role == 'member'
  end
end
