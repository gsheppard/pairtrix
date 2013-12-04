require 'spec_helper'

describe ApplicationHelper do
  describe '#yes_no' do
    subject { helper.yes_no(bool) }

    context "when 'true'" do
      let(:bool) { true }
      it { should == 'Yes' }
    end

    context "when 'false'" do
      let(:bool) { false }
      it { should == 'No' }
    end
  end

  describe '#avatar_for' do
    subject { helper.avatar_for(employee) }

    let(:employee) { double(:employee, do_not_pair: false, avatar?: has_avatar, avatar_url: avatar_url, name: 'name', solo_employee?: solo_employee, out_of_office_employee?: out_of_office_employee) }
    let(:solo_employee) { false }
    let(:out_of_office_employee) { false }

    context 'with avatar' do
      let(:has_avatar) { true }
      let(:avatar_url) { 's3/avatar.png' }

      it 'displays the uploaded avatar' do
        should =~ /s3/
      end
    end

    context 'without avatar' do
      let(:has_avatar) { false }
      let(:avatar_url) { '' }

      context 'as solo_employee' do
        let(:solo_employee) { true }

        it 'displays the default' do
          should =~ /solo/
        end
      end

      context 'as out_of_office_employee' do
        let(:out_of_office_employee) { true }

        it 'displays the default' do
          should =~ /office/
        end
      end

      context 'as normal employee' do
        it 'displays the default' do
          should =~ /avatar/
        end
      end
    end
  end
end
