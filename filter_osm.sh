#!/bin/bash -e
source env.sh

inputfile=${1:?Usage: $0 inputfile outputfile}
outputfile=${2:?Usage: $0 inputfile outputfile}

osmfilter "$inputfile" \
    --keep="building" \
    --keep="building:part" \
    --keep="disused:building" \
    --keep="abandoned:building" \
    --keep="demolished:building" \
    --keep="removed:building" \
    --keep="razed:building" \
    --keep="landuse" \
    --keep-ways="amenity" \
    --keep-relations="amenity" \
    --keep-ways="man_made" \
    --keep-relations="man_made" \
    --keep-ways="leisure" \
    --keep-relations="leisure" \
    --keep-ways="power=plant" \
    --keep-relations="power=plant" \
    --keep-ways="police" \
    --keep-relations="police" \
    --keep-ways="aeroway" \
    --keep-relations="aeroway" \
    --keep-ways="disused:aeroway" \
    --keep-relations="disused:aeroway" \
    --keep-ways="place" \
    --keep-relations="place" \
    --keep-ways="tourism" \
    --keep-relations="tourism" \
    --keep="type=boundary boundary=administrative" \
    -o="$outputfile"
