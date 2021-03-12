#!/bin/bash -e
source env.sh

# Running the analysis in one go for all of Germany took way too long. For some
# reason splitting by states helps to make it feasible.
echo ">>> Analyze OSM landuse data for all states"
echo -n "$STATES" | xargs --delimiter ' ' -P 4 -I region --verbose \
    psql -f buildings_without_landuse.sql -ab -v ON_ERROR_STOP=ON \
        -v building=region_building \
        -v landuse=region_landuse \
        -v buildings_without_landuse=region_buildings_without_landuse \
        -v building_clusters=region_building_clusters

echo ">>> Merge results from all states into one table"
(
    echo "DROP TABLE IF EXISTS building_clusters;"
    echo "CREATE TABLE building_clusters AS"
    for state in $STATES; do
        if [ -n "$first" ]; then
            echo "UNION ALL"
        fi
        first=false
        echo "SELECT building_count, geom FROM \"${state}_building_clusters\""
    done
    echo ";"
    echo "ALTER TABLE building_clusters ADD COLUMN id text;"
    echo "UPDATE building_clusters SET id = round(ST_X(ST_Centroid(geom))) || ',' || round(ST_Y(ST_Centroid(geom)));"
    echo "CREATE INDEX ON building_clusters USING GIST(geom);"
) |
psql -ab -v ON_ERROR_STOP=ON
