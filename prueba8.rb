puts 'The Amazing Alphabetizer'.center(60)
puts 'Type all the words you want and we will put them in alphabetic order for you'
puts 'It\'s easy! Just write the words followed by the \'Enter\' key. Once you finish just enter a blank line'

list = []
word = gets.chomp

while word != ''
  list.push word
  word = gets.chomp
end

puts list.sort