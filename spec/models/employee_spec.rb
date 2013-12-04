require 'spec_helper'

describe Employee do

  describe 'validations' do
    let(:employee) { Employee.new }

    before do
      employee.valid?
    end

    describe 'presence' do
      it 'validates the presence of first_name' do
        employee.should have(1).error_on(:first_name)
      end

      it 'validates the presence of last_name' do
        employee.should have(1).error_on(:last_name)
      end
    end

    describe 'uniqueness' do
      let!(:existing_employee) { FactoryGirl.create(:employee) }

      context 'with a common company' do
        before do
          employee.company = existing_employee.company
        end

        context 'with a common last_name' do
          before do
            employee.last_name = existing_employee.last_name
          end

          context 'with a unique first_name' do
            before do
              employee.first_name = 'xxx'
            end

            it 'validates the uniqueness of first_name' do
              employee.should have(0).error_on(:first_name)
            end
          end

          context 'with a duplicate first_name' do
            before do
              employee.first_name = existing_employee.first_name
            end

            it 'validates the uniqueness of first_name' do
              employee.should have(1).error_on(:first_name)
            end
          end
        end
      end

      context 'with different companies' do
        context 'with a common last_name' do
          before do
            employee.last_name = existing_employee.last_name
          end

          context 'with a unique first_name' do
            before do
              employee.first_name = 'xxx'
            end

            it 'validates the uniqueness of first_name' do
              employee.should have(0).error_on(:first_name)
            end
          end

          context 'with a duplicate first_name' do
            before do
              employee.first_name = existing_employee.first_name
            end

            it 'validates the uniqueness of first_name' do
              employee.should have(0).error_on(:first_name)
            end
          end
        end
      end
    end
  end

  describe '#name' do
    let(:employee) { FactoryGirl.build(:employee) }
    let(:full_name) { [employee.last_name, employee.first_name].join(', ') }

    it "returns the employee's full name" do
      employee.name.should == full_name
    end
  end

  describe '.ordered_by_last_name' do
    it 'orders the employees by last name' do
      first_employee = FactoryGirl.create(:employee, last_name: 'Aaaaa')
      second_employee = FactoryGirl.create(:employee, last_name: 'Zzzzz')

      employees = Employee.ordered_by_last_name
      first_index = employees.index(first_employee)
      second_index = employees.index(second_employee)

      expect(first_index).to be < second_index
    end
  end
end
