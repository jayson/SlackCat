#!/usr/bin/env python

# Adapted from https://github.com/rmmh/skybot/

import locale
import re
import time
import urllib
import urllib2
import urlparse
import json

from sys import argv

locale.setlocale(locale.LC_ALL, '')

base_url = 'http://gdata.youtube.com/feeds/api/'
url = base_url + 'videos/%s?v=2&alt=jsonc'
search_api_url = base_url + 'videos?v=2&alt=jsonc&max-results=1&q='
video_url = "http://youtube.com/watch?v=%s"

def get(*args, **kwargs):
    return open(*args, **kwargs).read()

def get_json(*args, **kwargs):
    return json.loads(get(*args, **kwargs))

def open(url, query_params=None, post_data=None, **kwargs):

    if query_params is None:
        query_params = {}

    query_params.update(kwargs)

    url = prepare_url(url, query_params)

    request = urllib2.Request(url, post_data)

    opener = urllib2.build_opener()

    return opener.open(request)

def to_utf8(s):
    if isinstance(s, unicode):
        return s.encode('utf8', 'ignore')
    else:
        return str(s)

def prepare_url(url, queries):
    if queries:
        scheme, netloc, path, query, fragment = urlparse.urlsplit(url)

        query = dict(urlparse.parse_qsl(query))
        query.update(queries)
        query = urllib.urlencode(dict((to_utf8(key), to_utf8(value))
                                  for key, value in query.iteritems()))

        url = urlparse.urlunsplit((scheme, netloc, path, query, fragment))

    return url

def get_video_description(vid_id):
    j = get_json(url % vid_id)

    if j.get('error'):
        return

    j = j['data']

    out = '\x02%s\x02' % j['title']

    if not j.get('duration'):
        return out

    out += ' - length \x02'
    length = j['duration']
    if length / 3600:  # > 1 hour
        out += '%dh ' % (length / 3600)
    if length / 60:
        out += '%dm ' % (length / 60 % 60)
    out += "%ds\x02" % (length % 60)

    if 'rating' in j:
        out += ' - rated \x02%.2f/5.0\x02 (%d)' % (j['rating'],
                j['ratingCount'])

    # The use of str.decode() prevents UnicodeDecodeError with some locales
    # See http://stackoverflow.com/questions/4082645/
    if 'viewCount' in j:
        out += ' - \x02%s\x02 views' % locale.format('%d',
                           j['viewCount'], 1)

    upload_time = time.strptime(j['uploaded'], "%Y-%m-%dT%H:%M:%S.000Z")
    out += ' - \x02%s\x02 on \x02%s\x02' % (j['uploader'],
                time.strftime("%Y.%m.%d", upload_time))

    if 'contentRating' in j:
        out += ' - \x034NSFW\x02'

    return out



j = get_json(search_api_url, q=argv[1:])

if 'error' in j:
    print 'error performing search'

if j['data']['totalItems'] == 0:
    print 'no results found'

vid_id = j['data']['items'][0]['id']

print get_video_description(vid_id) + " - " + video_url % vid_id
