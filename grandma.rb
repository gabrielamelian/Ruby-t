puts 'HELLO DEAR! HOW ARE YOU DOING?'

answer = gets.chomp

while answer != 'BYE'
  if answer != answer.upcase
    puts 'HUH?! SPEAK UP, SONNY!'
  else
    puts 'NO, NOT SINCE 1940'
  end
  answer = gets.chomp
end

puts 'OK, SEE YA SOON!'	