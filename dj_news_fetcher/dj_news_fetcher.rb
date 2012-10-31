load 'lib/functions.rb'

puts "Fetching artists..."
# get a list of artists we want to know news from 
artists = artists_get()

puts "Getting news about those artists..."
# get the news from good old Google news
news = news_get(artists, 30)

puts "Getting a list of emails to send the news to..."
# get list of emails to send mail to.
mails = mails_get()

#puts "Sending emails... (may take a while)"
# send email to interested parties.

#mails_send(mails, news)

finalize()