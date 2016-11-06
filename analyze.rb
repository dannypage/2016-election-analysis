require 'csv'
require 'time'

bf  = CSV.read('betfair.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
nyt = CSV.read('nyt.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
fte = CSV.read('538-parse.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
pw  = CSV.read('predictwise.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

nyt_score = {
  clinton: 0,
  trump:   0
}
nyt.each do |update|
  timestamp = Time.parse(update[:date])
  betfair = bf.find { |x| Time.parse(x[:timestamp]) >= timestamp}
  if update[:dem] > betfair[:clinton]
    nyt_score[:clinton] += 1
  elsif update[:rep] > betfair[:trump]
    nyt_score[:trump] += 1
  end
end

puts "Clinton: #{nyt_score[:clinton]}"
puts "Trump: #{nyt_score[:trump]}"
