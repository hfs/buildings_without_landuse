#!/usr/bin/env python3
import datetime
import logging
import os
import pathlib
import time

import maproulette

try:
    MAPROULETTE_API_KEY = os.environ['MAPROULETTE_API_KEY']
except KeyError:
    raise KeyError(
        "Please set the MapRoulette API key in environment variable MAPROULETTE_API_KEY. "
        "Get it from https://maproulette.org/user/profile")
PROJECT_ID = 41947

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

osmdump = pathlib.Path('data/thueringen-latest.osm.pbf')
osmdump_mtime = datetime.datetime.fromtimestamp(osmdump.stat().st_mtime)

config = maproulette.Configuration(api_key=MAPROULETTE_API_KEY)
challenge_api = maproulette.Challenge(config)

challenge = challenge_api.get_challenge_by_id(17667)['data']
if challenge['status'] == 3:
    logging.info("Rebuilding challenge %d", challenge['id'])
    # This also rebuilds the tasks
    result = challenge_api.update_challenge(challenge['id'], {'dataOriginDate': osmdump_mtime.isoformat()})
    logging.info("Result: %s", result)
