class Company < ActiveRecord::Base
  attr_accessible :name, :user_id

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :user_id

  belongs_to :user

  has_many :teams, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :membership_requests, dependent: :destroy
  has_many :company_memberships, dependent: :destroy

  after_commit :add_default_employees

  def has_membership_for?(user)
    company_memberships.detect { |company_membership| company_membership.user_id == user.id }
  end

  def available_users
    users_table = Arel::Table.new(:users)
    User.where(users_table[:id].not_in(company_membership_member_ids)).order("name")
  end

  private

  def company_membership_member_ids
    ids = company_memberships.select(&:persisted?).map(&:user_id)
    ids.any? ? ids : [0]
  end

  # we want to make sure the solo and out of office employees exist in every company
  def add_default_employees
    if transaction_include_action?(:create)
      self.employees.create!(first_name: "Employee", last_name: "Solo")
      self.employees.create!(first_name: "Out of", last_name: "Office")
    end
  end
end
