
# README

I've changed the websites table to a view (it could be a materialised view), as
crawling may be an ongoing process as new pages are added and it's not certain
how to be sure that we have comprehensively crawled the whole website.

Have we stopped crawling because we've visited everything, or because we've
encountered errors that have limited the depth of the crawl? This implementation
is not sophisticated enough to know.

By storing all links we can partition by the correlation_id assigned when a crawl
is first seeded by `rake crawl:vice`, or by timestamp (eg, counting all the unique
urls encountered in the last week may give more accurate numbers than all the uniq
links encountered in the last run). This allows us to see trends over time and
know whether the crawler is at least behaving consistently.

To seed the crawl queue with the first entry URL, and gather stats on the TLD
from Alexa, run

`rake crawl:vice`

There are three resque worker queues:

*crawl_links* fetches a page and parses out the internal and external links, and
adds these to another queue for the links to be persisted:

`COUNT=5 QUEUE=crawl_links rake environment resque:work`

*save_links* adds links in the database (isolating remote fetching and local
persistence):

`COUNT=5 QUEUE=save_links rake environment resque:work`

*save_stats* saves Alexa traffic data to the database:

`COUNT=5 QUEUE=save_stats rake environment resque:work`

NOTE: stats are fetched, pasred and added to the save_stats queue by the
crawl:vice rake task, but ideally they'd also be a fetch_stats queue.

Once starting `rails server`, the redis dashboard can be viewed at:

http://localhost:3000/resque/overview

Considerations:

* there is insufficient error handling and no retry logic
* should we observe robots txt?
* should we strip query parameters from links? dynamic links may present a
  'spider trap', but removing them may break pagination and discovery of
  legitimate content
