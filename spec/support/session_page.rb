module SessionPage
  def sign_in
    click_link('Sign in')
  end

  def expect_dashboard
    expect(page).to have_css('h3', text: 'Dashboard')
    expect(page).to have_css('h5', text: 'My Teams')
  end
end
