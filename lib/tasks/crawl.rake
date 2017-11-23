namespace :crawl do
 	task :vice => :environment do
    Stats.build('vice.com').perform
    Crawler.build("http://vice.com").perform
	end
end
