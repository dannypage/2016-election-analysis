require 'csv'
require 'time'

bf  = CSV.read('betfair.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
nyt = CSV.read('nyt.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
fte = CSV.read('538-parse.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
pw  = CSV.read('predictwise.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

bf.each do |betfair|
  betfair[:timestamp] = Time.parse(betfair[:timestamp])
end

nyt_score = {
  clinton: 0,
  trump:   0
}
nyt.each do |update|
  timestamp = Time.parse(update[:date])
  betfair = bf.find { |x| x[:timestamp] >= timestamp}
  if update[:dem] > betfair[:clinton]
    nyt_score[:clinton] += 1
  elsif update[:rep] > betfair[:trump]
    nyt_score[:trump] += 1
  end
end

puts "NYT:"
puts "Clinton: #{nyt_score[:clinton]}"
puts "Trump: #{nyt_score[:trump]}"

fte_score = {
  clinton: 0,
  trump:   0
}

fte.each do |update|
  timestamp = Time.parse(update[:timestamp])
  betfair = bf.find { |x| x[:timestamp] >= timestamp}
  if update[:clinton_po] > betfair[:clinton]
    fte_score[:clinton] += 1
  elsif update[:trump_po] > betfair[:trump]
    fte_score[:trump] += 1
  end
end

puts "FiveThirtyEight:"
puts "Clinton: #{fte_score[:clinton]}"
puts "Trump: #{fte_score[:trump]}"

pw_score = {
  clinton: 0,
  trump:   0
}

pw.each do |update|
  timestamp = Time.parse(update[:timestamp])
  betfair = bf.find { |x| x[:timestamp] >= timestamp}
  if update[:clinton] > betfair[:clinton]
    pw_score[:clinton] += 1
  elsif update[:trump] > betfair[:trump]
    pw_score[:trump] += 1
  end
end

puts "PredictWise:"
puts "Clinton: #{pw_score[:clinton]}"
puts "Trump: #{pw_score[:trump]}"
