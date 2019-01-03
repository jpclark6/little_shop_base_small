require 'rails_helper'

RSpec.describe 'Login/Logout workflow', type: :feature do
  describe 'logging in' do
    describe 'should complete successfully with correct credentials' do
      scenario 'regular users go to profile page' do
        create(:user, email:'a@b.com', password: 'password')

        visit login_path
        expect(page).to have_link('Log in')

        fill_in :email, with: 'a@b.com'
        fill_in :password, with: 'password'
        click_button 'Log in'

        expect(current_path).to eq(profile_path)
        expect(page).to have_content('You are logged in')
        expect(page).to have_link('Log out')

        visit login_path
        expect(current_path).to eq(profile_path)
        expect(page).to have_content('You are already logged in')
      end
      scenario 'merchant users go to dashboard page' do
        create(:merchant, email:'a@b.com', password: 'password')

        visit login_path

        fill_in :email, with: 'a@b.com'
        fill_in :password, with: 'password'
        click_button 'Log in'

        expect(current_path).to eq(dashboard_path)
        expect(page).to have_content('You are logged in')

        visit login_path
        expect(current_path).to eq(dashboard_path)
        expect(page).to have_content('You are already logged in')
      end
      scenario 'admin users go to home page' do
        create(:admin, email:'a@b.com', password: 'password')

        visit login_path

        fill_in :email, with: 'a@b.com'
        fill_in :password, with: 'password'
        click_button 'Log in'

        expect(current_path).to eq(root_path)
        expect(page).to have_content('You are logged in')

        visit login_path
        expect(current_path).to eq(root_path)
        expect(page).to have_content('You are already logged in')
      end
    end
    it 'should fail if credentials are wrong' do
      create(:user, email:'a@b.com', password: 'password')

      visit login_path

      fill_in :email, with: 'a@b.com'
      fill_in :password, with: 'different-password'
      click_button 'Log in'

      expect(current_path).to eq(login_path)
      expect(page).to have_content('Email or password is incorrect')
    end
    it 'should fail if my account is disabled' do
      create(:user, email:'a@b.com', password: 'password', active: false)

      visit login_path

      fill_in :email, with: 'a@b.com'
      fill_in :password, with: 'password'
      click_button 'Log in'

      expect(current_path).to eq(root_path)
      expect(page).to have_content('Sorry, your account is disabled')
    end
  end
  describe 'logging out' do
    it 'works correctly' do
      create(:user, email:'a@b.com', password: 'password')

      visit login_path

      fill_in :email, with: 'a@b.com'
      fill_in :password, with: 'password'
      click_button 'Log in'

      visit logout_path

      expect(current_path).to eq(root_path)
      expect(page).to have_content('You are logged out')
    end
    it 'empties my shopping cart when logging out' do
      create(:user, email:'a@b.com', password: 'password')
      item_1 = create(:item)

      visit login_path

      fill_in :email, with: 'a@b.com'
      fill_in :password, with: 'password'
      click_button 'Log in'

      visit item_path(item_1)
      click_button 'Add to Cart'
      expect(page).to have_content('Cart: 1')

      visit logout_path

      expect(current_path).to eq(root_path)
      expect(page).to have_content('You are logged out')
      expect(page).to have_content('Cart: 0')
    end
  end
end
