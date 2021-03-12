#!/bin/bash -e

DATE=$(date -d @$(stat --format %Y data/thueringen-latest.osm.pbf) +%Y-%m-%d)

mv data/*.geojson ../buildings_without_landuse_geojson/
pushd ../buildings_without_landuse_geojson/
git add -u
git commit -m "Update with data from $DATE"
git push
popd
