require 'csv'
require 'time'

puts "--------------"

def output(score, name)
  clinton_wager = score[:clinton]*100
  clinton_winnings = score[:clinton_bets].map {|x| 100*(1/x) }.reduce(0, :+)
  trump_wager  =score[:trump]*100
  trump_winnings = score[:trump_bets].map {|x| 100*(1/x)}.reduce(0, :+)
  wagered = clinton_wager + trump_wager
  clinton_roi = (clinton_winnings- wagered)/(clinton_wager+trump_wager)
  trump_roi = (trump_winnings - wagered)/(wagered)

  puts "#{name} Results:"
  puts "Clinton wagered: $#{clinton_wager}"
  puts "Clinton result : $#{clinton_winnings.round(2)}"
  puts "Clinton ROI: #{(clinton_roi*100).round(2)}%"
  puts "Trump wagered: $#{trump_wager}"
  puts "Trump result:  $#{trump_winnings.round(2)}"
  puts "Trump ROI: #{(trump_roi*100).round(2)}%"
  puts "--------------"
end

bf  = CSV.read('betfair.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
nyt = CSV.read('nyt.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
fte = CSV.read('538-parse.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
pw  = CSV.read('predictwise.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

bf.each do |betfair|
  betfair[:timestamp] = Time.parse(betfair[:timestamp])
end

nyt_score = {
  clinton: 0,
  trump:   0,
  clinton_bets: [],
  trump_bets: []
}
nyt.each do |update|
  timestamp = Time.parse(update[:date])
  betfair = bf.find { |x| x[:timestamp] >= timestamp}
  if update[:dem] > betfair[:clinton]
    nyt_score[:clinton] += 1
    nyt_score[:clinton_bets] << betfair[:clinton]
  elsif update[:rep] > betfair[:trump]
    nyt_score[:trump] += 1
    nyt_score[:trump_bets] << betfair[:trump]
  end
end

output(nyt_score, "NYT")

fte_score = {
  clinton: 0,
  trump:   0,
  clinton_bets: [],
  trump_bets: []
}

fte.each do |update|
  timestamp = Time.parse(update[:timestamp])
  betfair = bf.find { |x| x[:timestamp] >= timestamp}
  if update[:clinton_po] > betfair[:clinton]
    fte_score[:clinton] += 1
    fte_score[:clinton_bets] << betfair[:clinton]
  elsif update[:trump_po] > betfair[:trump]
    fte_score[:trump] += 1
    fte_score[:trump_bets] << betfair[:trump]
  end
end

output(fte_score, "FiveThirtyEight")

pw_score = {
  clinton: 0,
  trump:   0,
  clinton_bets: [],
  trump_bets: []
}

pw.each do |update|
  timestamp = Time.parse(update[:timestamp])
  betfair = bf.find { |x| x[:timestamp] >= timestamp}
  if update[:clinton] > betfair[:clinton]
    pw_score[:clinton] += 1
    pw_score[:clinton_bets] << betfair[:clinton]
  elsif update[:trump] > betfair[:trump]
    pw_score[:trump] += 1
    pw_score[:trump_bets] << betfair[:trump]
  end
end

output(pw_score, "PredictWise")
