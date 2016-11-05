require 'mechanize'
require 'open-uri'
require 'nori'

agent = Mechanize.new{ | agent| agent.history.max_size = 0}
parser = Nori.new

agent.user_agent = 'Mozilla/5.0'
agent.pluggable_parser.default = Mechanize::Download

agent.get("http://projects.fivethirtyeight.com/2016-election-forecast/updates.json").save!("./fivethirtyeight.json")
agent.get("http://table-cache1.predictwise.com/history/table_1523.json").save!("./predictwise.json")
agent.get("http://elections.huffingtonpost.com/pollster/2016-general-election-trump-vs-clinton.csv").save!("./huffingtonpost.csv")
agent.get("https://static01.nyt.com/newsgraphics/2016/08/05/presidential-forecast/a7acb9de98af5f9e93328aaa173f8d64cf6b04f4/timeseries.csv").save!("./nyt.csv")
