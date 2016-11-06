How to:

- Install Ruby and a few gems.
- Optional: Run "ruby download.rb" for up to date files. NYT needs a specific URL, they cache their file.
- Optional: Run "ruby parse.rb" to turn the JSON into CSVs that can be analysed.
- Run "ruby analyze.rb" to output results
- Note that it analyzes updates only starting on July 8th, as to set a baseline for all models. 4 months worth should cover the core of the election.

Still to do:
- Graphs!

Data Feeds:
- predictwise	http://table-cache1.predictwise.com/history/table_1523.json
- nyt	https://static01.nyt.com/newsgraphics/2016/08/05/presidential-forecast/54c9e640a5c8d15d126d86480a2245bded598d0c/timeseries.csv
- huffpo	http://elections.huffingtonpost.com/pollster/2016-general-election-trump-vs-clinton.csv
- fivethirtyeight	http://projects.fivethirtyeight.com/2016-election-forecast/updates.json

To grab for the year end evaluation:
- pkremp-os https://github.com/pkremp/polls
- pollydata 
