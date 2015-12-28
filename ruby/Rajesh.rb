puts " Hello Rajesh!"
puts "hello".length
print "hello".length

print " Hello Rajesh \n"

print "Rajesh".reverse + "\n"

puts "stay calm".upcase
puts "LOL funny joke".downcase

puts 10 + 2

print " without Flost for 1/2 \n"
puts 1/2

print " With Float of 1/2 \n"
puts 1/2.0
puts Float(1)/2

print " Modulo of 8 % 3 \n "
puts 8%3

puts -100.abs
puts 20.9.round
puts 3.1456.round(2)
A=(32.71 * 15)/100
puts A.round(2)

puts (0.15 * 32.71).round(2)

name = "Yukihiro Matsumoto"
puts "Welcome " + name + ", it is nice to meet you!"
name =" Rajesh Chandramohan"
puts "Welcome " + name + ", it is nice to meet you!"
puts "Welcome #{name}, it is nice to meet you!"

# This is a comment.
# # I can describe my program in depth using human language!
#
code = "M.E?CIQN E?RS, D?NA EQC,IN S,,I Z?TQAM,"
B=code.length
C=code[1,B]
puts C
#code.reverse.chop.reverse   Another method
##C[11]="A EW? O"
C.insert 11, "A EW? O"
puts C
D=C.gsub(/[Q?,]/,'')
puts D
puts D.downcase.reverse.capitalize
