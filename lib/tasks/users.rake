# encoding: utf-8
namespace :users do

  desc "Создать нового пользователя"
  task :create => :environment do
    unless ENV['email']
      puts "Укажите эл. почту. Например:"
      puts "bundle exec rake users:create email=test@example.com"
      exit 1
    end

    user = User.where(email: ENV['email']).first
    if user
      user.generate_reset_auth_token!
    else
      user = User.new
      user.email = ENV['email']
      user.save!
    end

    token = CGI.escape(user.reset_auth_token)
    puts 'Запустите сервер, перейдите по ссылке и выберите способ входа:'
    puts "http://localhost:3000/users/#{user.id}/auth?token=#{token}"
  end

end
