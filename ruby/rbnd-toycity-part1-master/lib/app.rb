require 'json'

path = File.join(File.dirname(__FILE__), '../data/products.json')
file = File.read(path)
$toys_data = JSON.parse(file)

# Print today's date
time = Time.new
puts time.strftime("%Y-%m-%d %H:%M:%S")

puts "                     _            _       "
puts "                    | |          | |      "
puts " _ __  _ __ ___   __| |_   _  ___| |_ ___ "
puts "| '_ \\| '__/ _ \\ / _` | | | |/ __| __/ __|"
puts "| |_) | | | (_) | (_| | |_| | (__| |_\\__ \\"
puts "| .__/|_|  \\___/ \\__,_|\\__,_|\\___|\\__|___/"
puts "| |                                       "
puts "|_|                                       "


# For each product in the data set:
  # Print the name of the toy
  # Print the retail price of the toy
  # Calculate and print the total number of purchases
  # Calcalate and print the total amount of sales
  # Calculate and print the average price the toy sold for
  # Calculate and print the average discount based off the average sales price


# For each product in the data set:
$toys_data["items"].each do |toy|
  tsales=0
  avprice=0
  # Print the name of the toy
  puts toy["title"]
  30.times {print  "*****"}
  print "\n"
  print "Retail Price:"
  puts "$#{toy["full-price"]}"

  print "Total Purchases:"
  puts toy["purchases"].count

  print "Total Sales:"
  toy["purchases"].each do |pp|
    tsales = tsales + pp["price"]
  end
  puts "$#{tsales}"

  print "Average Price:"
  avprice=tsales/(toy["purchases"].count)
  puts "$" + avprice.to_s

  print "Average Discount:"
  #puts toy["averagediscount:"]
  #puts (100-(b/(toy["full-price"]).to_f)*100).to_s + "%"
  result= (100-(avprice/(toy["full-price"]).to_f)*100) #.round(2)
  #puts "#{result} %"
  puts result.round(2).to_s + "%"

  30.times {print  "*****"}
  print "\n\n"
end


	puts " _                         _     "
	puts "| |                       | |    "
	puts "| |__  _ __ __ _ _ __   __| |___ "
	puts "| '_ \\| '__/ _` | '_ \\ / _` / __|"
	puts "| |_) | | | (_| | | | | (_| \\__ \\"
	puts "|_.__/|_|  \\__,_|_| |_|\\__,_|___/"
	puts

# For each brand in the data set:
  # Print the name of the brand
  # Count and print the number of the brand's toys we stock
  # Calculate and print the average price of the brand's toys
  # Calculate and print the total revenue of all the brand's toy sales combined
def brands
    #@brands ||= $toys_data["items"].map { |toy| toy["brand"] }.uniq
    $toys_data["items"].map { |toy| toy["brand"] }.uniq
end


def products_by(brand)
  $toys_data["items"].select { |toy| toy["brand"] == brand }
end

totbrandsales=0
brands.each do |brand|
    puts brand
    30.times {print  "*****"}
    print "\n"
    brand_price=0
    avg_price=0
    products_by(brand).each do |product|
          #puts product["full-price"]
          brand_price = brand_price + product["full-price"].to_f
          product["purchases"].each do |value|
             totbrandsales = totbrandsales + value["price"]
          end
          #puts totbrandsales
    end
          print "Number of Products: "
          puts products_by(brand).length

          print "Average Product Price: "
          avg_price=brand_price/products_by(brand).length
          #puts avg_price.round(2)
          puts "$" + avg_price.round(2).to_s  # This method is to print $ symbold and variable value as string 
          print "Total Sales: "
          puts "$#{totbrandsales.round(2)}"
          print "\n"
end
