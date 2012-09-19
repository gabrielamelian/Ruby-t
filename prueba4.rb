puts 'Hello! What is your name?'
name = gets.chomp
puts 'Thank you! May I know your first surname?'
surname = gets.chomp
puts 'That is great! And do you have other surname as well?'
surname2 = gets.chomp
allname = name + surname + surname2
puts 'Do you know that your name has ' + allname.length.to_s + ' characters total?'