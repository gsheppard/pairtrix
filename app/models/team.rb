class Team < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :company_id

  belongs_to :company

  has_many :team_memberships, dependent: :destroy
  has_many :employees, through: :team_memberships

  has_many :pairing_days, dependent: :destroy
  has_many :pairs, through: :pairing_days

  after_commit :add_default_team_memberships, on: :create

  def times_paired(left, top)
    membership_hash[left.employee_id].key?(top.employee_id) ? membership_hash[left.employee_id][top.employee_id] : 0
  end

  def active_real_memberships
    active_memberships.reject { |membership| membership.solo_or_out_of_office? }
  end

  def checksum
    Digest::MD5.hexdigest(employee_id_string)
  end

  private

  def employee_id_string
    employees.map(&:id).sort.join('-')
  end

  def active_memberships
    @active_memberships ||= begin
                              active_employee_ids = team_memberships.map(&:employee_id)
                              team_memberships.where(employee_id: active_employee_ids)
                            end
  end

  def active_membership_pairs
    pairing_days.where('pairing_date >= ?', 2.weeks.ago.to_date).map do |pairing_day|
      pairing_day.pairs.select { |pair| pair.memberships_active?(active_memberships) }
    end.compact.flatten
  end

  def membership_hash
    @membership_hash ||= PairMatrixCalculator.new(active_membership_pairs, team_memberships).complete_pair_hash
  end

  # we want to make sure the solo and out of office employees exist on every team
  def add_default_team_memberships
    team_memberships.create!(employee_id: company.employees.solo_employee.id)
    team_memberships.create!(employee_id: company.employees.out_of_office_employee.id)
  end
end
