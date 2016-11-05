require 'csv'
require 'json'
require 'time'

CSV.open("538-parse.csv", "wb") do |output|
  output << ['timestamp', 'clinton-pp', 'clinton-po', 'clinton-nc',
          'trump-pp', 'trump-po', 'trump-nc']
  document = JSON.parse(File.open("538-updates.json").read)
  document['updates'].each do |update|
    output << {
      unix_timestamp: update['added'],
      clinton_pp: update['diffs']['polls-plus'].find {|x| x['candidate']=='Clinton'}['winprob']['current'].to_f,
      clinton_po: update['diffs']['polls-only'].find {|x| x['candidate']=='Clinton'}['winprob']['current'].to_f,
      clinton_nc: update['diffs']['now-cast'].find   {|x| x['candidate']=='Clinton'}['winprob']['current'].to_f,
      trump_pp: update['diffs']['polls-plus'].find {|x| x['candidate']=='Trump'}['winprob']['current'].to_f,
      trump_po: update['diffs']['polls-only'].find {|x| x['candidate']=='Trump'}['winprob']['current'].to_f,
      trump_nc: update['diffs']['now-cast'].find   {|x| x['candidate']=='Trump'}['winprob']['current'].to_f
    }.values
  end
end

CSV.open("betfair.csv", "wb") do |output|
  output << ['timestamp', 'clinton', 'trump']
  document = JSON.parse(File.open("predictwise.json").read)
  document['history'].each do |history|
    output << {
      timestamp: Time.strptime(history['timestamp'],'%m-%d-%Y %I:%M%p'),
      clinton: history['table'][0][2].gsub(/[^0-9.]/,""),
      trump: history['table'][1][2].gsub(/[^0-9.]/,"")
    }.values
  end
end

CSV.open("predictwise.csv", "wb") do |output|
  output << ['timestamp', 'clinton', 'trump']
  document = JSON.parse(File.open("predictwise.json").read)
  document['history'].each do |history|
    output << {
      timestamp: Time.strptime(history['timestamp'],'%m-%d-%Y %I:%M%p'),
      clinton: history['table'][0][1].gsub(/[^0-9.]/,""),
      trump: history['table'][1][1].gsub(/[^0-9.]/,"")
    }.values
  end
end
