require 'twilio-ruby'

#to find these visit twilio.com/user/account (i think)
account_sid = "AC2374cd139567c989856664e9c533ccf0"
auth_token = "7677a62b1e754b223a89b23234920739"

def to 

@client = Twilio::REST::Client.new account_sid, auth_token

@message = @client.messages.create(
	to: to,
	from: "+17735969397",
	body: "hello world")