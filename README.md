# hospital-occupancy-tracker-R
cron job that collects data for <a href = "https://github.com/jlomako/Montreal-ER">Montreal-ER</a> app

### notes to myself:
* to read csv with french characters use <code>encoding = "latin1"</code>
* R automatically generates Rplot.pdf together with ggsave --> pdf won't be saved with <code>git add data/* img/*</code>
* runs on macos-11 since GH stopped supporting macos-10.15
* data source wasn't available from Sep 15-19, replaced missing data with data from pdfscraper
* created new yml file that reads packages from renv.lock
* bot runs on ubuntu now
