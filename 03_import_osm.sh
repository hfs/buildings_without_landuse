#!/bin/bash -e
source env.sh

echo ">>> Convert OSM dumps into O5M format for filtering..."
for state in $STATES; do
    if [ data/$state-latest.osm.pbf -nt data/$state-latest.o5m ]; then
        echo $state
    fi
done | xargs --verbose -P 4 -I region osmconvert data/region-latest.osm.pbf -o=data/region-latest.o5m
echo ">>> Done"

echo ">>> Filter OSM data..."
for state in $STATES; do
    if [ data/$state-latest.o5m -nt data/$state-filtered.o5m ]; then
        echo $state
    fi
done | xargs --verbose -P 4 -I region ./filter_osm.sh data/region-latest.o5m data/region-filtered.o5m
echo ">>> Done"

echo ">>> Import filtered OSM data into PostGIS database..."
# As this is IO bound for me, it wouldn't help to parallelize it
for state in $STATES; do
    echo ">>> $state"
    rm -f data/nodes.bin
    # Prefix is evaluated by Lua script
    export OSM2PGSQL_PREFIX="${state}_"
    osm2pgsql --create --slim --cache $MEMORY --number-processes 8 \
        --flat-nodes data/nodes.bin --style buildings_and_landuse.lua \
        --output flex --proj 3035 data/$state-filtered.o5m
done
rm data/nodes.bin
