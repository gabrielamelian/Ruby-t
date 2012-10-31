require 'sqlite3'
require 'rss'
require 'open-uri'
require 'net/http'
require 'gmail' 
require 'sanitize'


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

$conn = SQLite3::Database.open 'database/database.db'
$conn.results_as_hash = true

##
# returns a list of artists, ordered by popularity, obtained from
# the top 100 djs in the world
# @return array of strings, each string being an artist
#
def artists_get()
	rows = $conn.execute('SELECT * FROM artists')
	
	# convert back into array.
	artists = []
	rows.each do |row|
		artists.push(row['name'])
	end
	
	return artists
end

##
# returns a list of news, about live concerts that artists are going to perform
# @param artists an array with artists to fetch news about. As returned by artists_get
# @param number number of news to fetch. maximum 100.
# @return returns number news, in an array such as this:
# 	[{
# 		"title" => "New",
#		"link" => "http://google.com/deadmau_rules",
#		"guid" => "tag:news.google.com,2005:cluster=http://www.sohood.com/2012/10/video-interview-why-deadmau5-hates-dubstep/",
#		"description" => "description",
#		"pubdate" => "Sat, 06 Oct 2012 17:18:49 GMT"
# 	}]
#
def news_get(artists, number)
	# build the query
	query = '"' + artists.join('" OR "') + '"'
	
	# uri encode the query
	query = URI::encode(query)
	
	# get the actual news
	url = 'http://api.feedzilla.com/v1/categories/6/articles/search.rss?q=' + query + '&output=rss&num=' + number.to_s
	puts url
	news_array = []
	open(url) do |rss|
		feed = RSS::Parser.parse(rss)
		feed.items.each do |item|
			news = {
				"title" => item.title,
				"link" => item.link,
				"guid" => Sanitize.clean(item.guid.to_s),
				"description" => item.description,
				"pubdate" => item.pubDate
			}
			
			news_array.push(news)
		end
	end
	
	puts news_array.inspect
	exit
		
	# get the intersection between the news we just fetched and the news in the database
	news_already_sent = news_already_sent_get(news_array)
	
	# delete the news we already sent from this array
	puts news_array.length
	news_array = news_array - news_already_sent
	puts news_array.length
	
	return news_array
end



##
# returns the news that already have been sent to users.
# @parameter news to check for
#
def news_already_sent_get(news_array)
	# get an array of guids.
	guid_list = []
	news_array.each do |news|
		guid_list.push news['guid']
	end
	
	# convert it to a string so as to use it in the SQL.	
	guid_list = '"'+guid_list.join('", "')+'"'
	tmp = $conn.execute('SELECT * FROM news WHERE guid IN ('+guid_list+')')
	
	# loop through originals so as to return the correct ones
	already_sent = []
	tmp.each do |t|
		guid = t['guid']
		news_array.each do |news|
			# this means it already exists
			if news['guid'] == guid
				already_sent.push(news)
			end
		end
	end

	return already_sent
end

##
# Returns a list of mails (of active subscribers) from the database.
# @return array of hashes, each hash being in the following format:
# {"owner_name" => "Gabriela", "mail" => "test@mail.com"}
#
def mails_get
	mails = $conn.execute('SELECT * FROM mails')
	return mails
end

##
# sends mails to users about news.
# @param mails a list of mails, as returned by mails_get.
# @param news a list of news, as returned by news_get.
#
def mails_send(mails, news_array)
	# get the common mail format.
	file = File.open('templates/email_format.tpl', 'r')
	format = file.read()
	
	# generate the news string for text-only email clients.
	news_string_text = ""
	news_array.each do |news|
		news_string_text += news['title'] + "\n" + "Read more at: " + news['link'] + "\n\n"
	end
	
	format = format.sub('{news}', news_string_text)
	
	#for each mail we have to send, send it.
	mails.each do |mail|
		message = format.sub('{owner_name}', mail['owner_name'])
		mail_send(mail, message)		
	end
	
	# mark news as already sent.
	news_save(news_array)
end

##
# saves news in the database so as to mark them as already sent.
# @param news_array the news to mark as read.
# 
def news_save(news_array)
	news_array.each do |news|
		# @TODO: save pubdate too. it was causing a bug so I removed it.
		$conn.execute("INSERT INTO news (title, guid, description) VALUES (?, ?, ?)", 
					news['title'], news['guid'], news['description'])
	end
end

##
# Sends a message to mail address.
# @param mail representation of a mail row as returned by mails_get
# @param message message to send to the user.
# @TODO: make it so it doesn't disconnect after sending an email
#
def mail_send(mail, message)
	Gmail.connect('metaldroope@gmail.com', 'superpassword123') do |gmail|
		email = gmail.compose do
		  to mail['mail']
		  subject "Top DJ News"
		  body message
		end
		email.deliver!
	end
end

##
# Closes open connections
#
def finalize()
	$conn.close
end
