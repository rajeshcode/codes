
A=[1,2,3,4].inject(0, &:+) 
puts A

puts [[:first_name, 'Shane'], [:last_name, 'Harvie']].inject({}) { |result, (key, value)| result.update({key=>value}) }
