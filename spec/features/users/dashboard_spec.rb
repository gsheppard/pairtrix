require 'spec_helper'

feature 'sign in' do
  scenario 'displays the user dashboard' do
    visit(root_path)
    sign_in
    expect_dashboard
  end
end
