require 'csv'
require 'json'

CSV.open("results.csv", "wb") do |output|
  output << ['unix_timestamp', 'clinton-pp', 'clinton-po', 'clinton-nc',
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
