require 'csv'
require 'time'
require 'descriptive_statistics'

puts "--------------"

$date_cutoff = Time.new(2016,07,8)

def kelly_bet(odds,prob,bankroll)
  kelly_fraction = 0.5
  ((((((1/odds)*prob)-1)/((1/odds)-1))*bankroll)*kelly_fraction).floor
end

def output(score, name)
  clinton_expected = 1/1.2
  trump_expected = 1/5.9
  clinton_wager = score[:clinton]*100
  clinton_winnings = score[:clinton_bets].map {|x| 100*(1/x) }.reduce(0, :+)
  trump_wager  =score[:trump]*100
  trump_winnings = score[:trump_bets].map {|x| 100*(1/x)}.reduce(0, :+)
  wagered = clinton_wager + trump_wager
  clinton_roi = (clinton_winnings- wagered)/wagered
  trump_roi = (trump_winnings - wagered)/wagered
  xROI = (clinton_winnings*clinton_expected + trump_winnings*trump_expected-wagered)/wagered

  puts "#{name} Results:"
  puts "Current xROI:  #{(xROI*100).round(2)}%"
  puts "Current StDev: #{[clinton_roi, trump_roi].standard_deviation.round(2)}"
  puts "Clinton wagered: $#{clinton_wager}"
  puts "Clinton result : $#{clinton_winnings.round(2)}"
  puts "Clinton ROI: #{(clinton_roi*100).round(2)}%"
  puts "Trump wagered: $#{trump_wager}"
  puts "Trump result:  $#{trump_winnings.round(2)}"
  puts "Trump ROI: #{(trump_roi*100).round(2)}%"
  puts "--------------"
end

def kelly_output(score, name, clinton_key, trump_key)
  clinton_expected = 0.8
  trump_expected = 0.2
  clinton_wager = score[clinton_key].map{|x| x[:size] }.reduce(0, :+)
  clinton_winnings = score[clinton_key].map{|x| 1/x[:bet] * x[:size] }.reduce(0, :+)
  trump_wager = score[trump_key].map{|x| x[:size] }.reduce(0, :+)
  trump_winnings = score[trump_key].map{|x| 1/x[:bet] * x[:size] }.reduce(0, :+)
  wagered = clinton_wager + trump_wager
  clinton_roi = (clinton_winnings- wagered)/wagered
  trump_roi = (trump_winnings - wagered)/wagered
  xROI = (clinton_winnings*clinton_expected + trump_winnings*trump_expected-wagered)/wagered

  puts "#{name} Results:"
  puts "Current xROI: #{(xROI*100).round(2)}%"
  puts "Current StDev: #{[clinton_roi, trump_roi].standard_deviation.round(2)}"
  puts "Clinton wagered: $#{clinton_wager}"
  puts "Clinton result : $#{clinton_winnings.round(2)}"
  puts "Clinton ROI: #{(clinton_roi*100).round(2)}%"
  puts "Trump wagered: $#{trump_wager}"
  puts "Trump result:  $#{trump_winnings.round(2)}"
  puts "Trump ROI: #{(trump_roi*100).round(2)}%"
  puts "Remaining Bankroll: #{score[:bankroll]}" if clinton_key == :clinton_kelly_bankroll
  puts "Remaining Bankroll: #{score[:rolling_bankroll]}" if clinton_key == :clinton_rolling
  puts "--------------"
end

def analyse(updates, betfair_data, clinton_key, trump_key, timestamp_key, name)
  score_card = {
    clinton: 0,
    trump:   0,
    clinton_bets: [],
    trump_bets: [],
    clinton_kelly: [],
    trump_kelly: [],
    clinton_kelly_bankroll: [],
    trump_kelly_bankroll: [],
    clinton_rolling: [],
    trump_rolling: [],
    bankroll: 1_000_000,
    rolling_bankroll: 0
  }
  updates.each do |update|
    timestamp = Time.parse(update[timestamp_key])
    timestamp = Time.new(timestamp.year, timestamp.month, timestamp.day, 12,0,0) if timestamp_key == :date
    next if timestamp < $date_cutoff
    betfair = betfair_data.find { |x| x[:timestamp] >= timestamp}
    next if betfair.nil?
    score_card[:rolling_bankroll] += 100
    if update[clinton_key] > betfair[:clinton]
      score_card[:clinton] += 1
      score_card[:clinton_bets] << betfair[:clinton]
      kelly = kelly_bet(betfair[:clinton], update[clinton_key], 100)
      score_card[:clinton_kelly] << {bet: betfair[:clinton], size: kelly, prob: update[clinton_key]} unless kelly <= 0
      kelly_bankroll = kelly_bet(betfair[:clinton], update[clinton_key], score_card[:bankroll])
      score_card[:clinton_kelly_bankroll] << {bet: betfair[:clinton], size: kelly_bankroll, prob: update[clinton_key]} unless kelly_bankroll <= 0
      score_card[:bankroll] -= kelly_bankroll
      kelly_rolling = kelly_bet(betfair[:clinton], update[clinton_key], score_card[:rolling_bankroll])
      score_card[:clinton_rolling] << {bet: betfair[:clinton], size: kelly_rolling, prob: update[clinton_key]} unless kelly_rolling <= 0
      score_card[:rolling_bankroll] -= kelly_rolling
    elsif update[trump_key] > betfair[:trump]
      score_card[:trump] += 1
      score_card[:trump_bets] << betfair[:trump]
      kelly = kelly_bet(betfair[:trump], update[trump_key], 100)
      score_card[:trump_kelly] << {bet: betfair[:trump], size: kelly, prob: update[trump_key]} unless kelly <= 0
      kelly_bankroll = kelly_bet(betfair[:trump], update[trump_key], score_card[:bankroll])
      score_card[:trump_kelly_bankroll] << {bet: betfair[:trump], size: kelly_bankroll, prob: update[trump_key]} unless kelly_bankroll <= 0
      score_card[:bankroll] -= kelly_bankroll
      kelly_rolling = kelly_bet(betfair[:trump], update[trump_key], score_card[:rolling_bankroll])
      score_card[:trump_rolling] << {bet: betfair[:trump], size: kelly_rolling, prob: update[trump_key]} unless kelly_rolling <= 0
      score_card[:rolling_bankroll] -= kelly_rolling
    end
  end

  output(score_card, name)
  kelly_output(score_card, "#{name} Kelly ($100/update)", :clinton_kelly, :trump_kelly)
  kelly_output(score_card, "#{name} Kelly Bankroll", :clinton_kelly_bankroll, :trump_kelly_bankroll)
  kelly_output(score_card, "#{name} Kelly Rolling", :clinton_rolling, :trump_rolling)
end

bf  = CSV.read('betfair.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
nyt = CSV.read('nyt.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
fte = CSV.read('538-parse.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
pw  = CSV.read('predictwise.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

bf.each do |betfair|
  betfair[:timestamp] = Time.parse(betfair[:timestamp])
end

analyse(nyt, bf, :dem, :rep, :date, "NYT")
analyse(fte, bf, :clinton_po, :trump_po, :timestamp, "FiveThirtyEight Polls-Only")
analyse(fte, bf, :clinton_pp, :trump_pp, :timestamp, "FiveThirtyEight Polls-Plus")
analyse(fte, bf, :clinton_nc, :trump_nc, :timestamp, "FiveThirtyEight NowCast")
analyse(pw, bf, :clinton, :trump, :timestamp, "PredictWise")
