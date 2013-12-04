class Employee < ActiveRecord::Base

  mount_uploader :avatar, AvatarUploader

  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :first_name, scope: [:company_id, :last_name]
  validates_presence_of :company_id

  belongs_to :company

  has_many :team_memberships, inverse_of: :employee, dependent: :destroy
  has_many :teams, through: :team_memberships

  class << self
    def ordered_by_last_name
      order('last_name ASC, first_name ASC')
    end

    def solo_employee
      where(last_name: 'Solo').first
    end

    def out_of_office_employee
      where(last_name: 'Office').first
    end
  end

  def solo_or_out_of_office?
    solo_employee? || out_of_office_employee?
  end

  def name
    [last_name, first_name].join(', ')
  end

  def solo_employee?
    id == company.employees.solo_employee.try(:id)
  end

  def out_of_office_employee?
    id == company.employees.out_of_office_employee.try(:id)
  end
end
