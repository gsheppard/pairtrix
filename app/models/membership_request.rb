class MembershipRequest < ActiveRecord::Base

  STATUSES = ['Pending', 'Approved', 'Denied']

  belongs_to :company
  belongs_to :user

  validates_presence_of :company_id
  validates_presence_of :user_id
  validates_presence_of :status

  validates_inclusion_of :status, in: MembershipRequest::STATUSES, if: :status

  before_create :generate_hash_key

  class << self
    def pending
      where(status: 'Pending')
    end
  end

  def pending?
    status == 'Pending'
  end

  def approved?
    status == 'Approved'
  end

  def denied?
    status == 'Denied'
  end

  private

  def generate_hash_key
    self.hash_key = Digest::MD5.hexdigest("#{company_id}:#{user_id}:#{Time.current.usec}")
  end
end
