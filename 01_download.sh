#!/bin/bash -e
source env.sh

cd data
for state in $STATES; do
    region=europe/germany/$state
    echo ">>> Downloading OpenStreetMap dump for region '$region'"
    wget "http://download.geofabrik.de/$region-latest.osm.pbf" \
        --timestamping
done
