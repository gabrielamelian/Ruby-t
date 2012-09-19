puts 'HELLO DEAR! HOW ARE YOU DOING?'

times = 0

while times < 3
  answer = gets.chomp
 
  if answer == 'BYE'
    times = times + 1
  end
   
  if answer != 'BYE' 
    times = 0
    if answer != answer.upcase
      puts 'HUH?! SPEAK UP, SONNY!'
    else
      puts 'NO, NOT SINCE ' + (rand (1920..1950)).to_s + '.'
    end
  end

end

puts 'OK, SEE YA SOON!'	