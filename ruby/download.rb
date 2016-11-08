require 'mechanize'
require 'open-uri'
require 'nori'

agent = Mechanize.new{ | agent| agent.history.max_size = 0}
parser = Nori.new

agent.user_agent = 'Mozilla/5.0'
agent.pluggable_parser.default = Mechanize::Download

agent.get("http://projects.fivethirtyeight.com/2016-election-forecast/updates.json").save!("./fivethirtyeight.json")
agent.get("http://table-cache1.predictwise.com/history/table_1523.json").save!("./predictwise.json")
agent.get("https://static01.nyt.com/newsgraphics/2016/08/05/presidential-forecast/a6e9299e78d0577c3487fe82b3f8308050e7a491/timeseries.csv").save!("./nyt.csv")
agent.get("https://static01.nyt.com/newsgraphics/2016/08/05/presidential-forecast/b23f801bc04e80241bf5b415d3a7a7ae869e2695/comparison-table.csv").save!("./summary-state-probs.csv")
