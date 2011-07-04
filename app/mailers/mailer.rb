# encoding: utf-8
class Mailer < ActionMailer::Base
  default from: 'no-reply@dis.spbstu.ru'
  layout 'mail'
  
  def welcome(inviter, user)
    @user    = user
    @inviter = inviter
    mail to: user.email, subject: 'Добро пожаловать на сайт кафедры РИС'
  end
  
  def change_auth(requester, user)
    @user      = user
    @requester = requester
    mail to: user.email, subject: 'Смена входа на сайт кафедры РИС'
  end
end
