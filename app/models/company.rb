class Company < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :user_id

  belongs_to :user

  has_many :teams, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :membership_requests, dependent: :destroy
  has_many :company_memberships, dependent: :destroy

  after_commit :add_default_employees, on: :create

  def real_employees
    employees.reject(&:solo_or_out_of_office?)
  end

  def has_membership_for?(user)
    company_memberships.detect { |company_membership| company_membership.user_id == user.id }
  end

  def available_users
    users_table = Arel::Table.new(:users)
    User.where(users_table[:id].not_in(company_membership_member_ids)).order("name")
  end

  def available_employees
    employees.ordered_by_last_name.select do |employee|
      employee.team_memberships.empty? && !employee.solo_or_out_of_office?
    end.compact
  end

  private

  def company_membership_member_ids
    ids = company_memberships.select(&:persisted?).map(&:user_id)
    ids.any? ? ids : [0]
  end

  # we want to make sure the solo and out of office employees exist in every company
  def add_default_employees
    employees.create!(first_name: "Employee", last_name: "Solo")
    employees.create!(first_name: "Out of", last_name: "Office")
  end
end
