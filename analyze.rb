require 'csv'

bf  = CSV.read('betfair.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
nyt = (File.open('nyt.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
fte = (File.open('538-parse.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
pw  = (File.open('predictwise.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

#For Each Update
  bf.find { |x| Time.parse(x[:timestamp]) > update}
  # store value into package
#end 
