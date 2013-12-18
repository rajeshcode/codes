#!/usr/bin/env python
#### https://pypi.python.org/pypi/futures/#downloads
#### Backport of the concurrent.futures package from Python 3.2
import futures
import urllib2

URLS = ['http://www.foxnews.com/',
        'http://www.cnn.com/',
        'http://europe.wsj.com/',
        'http://www.bbc.co.uk/',
        'http://google.com/',
        'http://yahoo.com/']

def load_url(url, timeout):
    return urllib2.urlopen(url, timeout=timeout).read()

with futures.ThreadPoolExecutor(max_workers=5) as executor:
    future_to_url = dict((executor.submit(load_url, url, 60), url)
                         for url in URLS)

    for future in futures.as_completed(future_to_url):
        url = future_to_url[future]
        if future.exception() is not None:
            print '%r generated an exception: %s' % (url,
                                                     future.exception())
        else:
            print '%r page is %d bytes' % (url, len(future.result()))
