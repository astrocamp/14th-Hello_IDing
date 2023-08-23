class UserMailer < Devise::Mailer
  default template_path: "users/mailer"

  def confirmation_instructions(record, token, opt = {})
    headers['custom-header'] = 'Bar'
    opt[:subject] = '加入 iDing 前請驗證您的信箱'
    opt[:from] = 'noreply@iding.cc'
    super
  end
end