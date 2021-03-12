#!/bin/bash -e
source env.sh
echo ">>> Export results as GeoJSON file"

mkdir -p data
psql -t -v ON_ERROR_STOP=ON > data/buildings_without_landuse.geojson <<EOF
    SELECT json_build_object(
        'type', 'FeatureCollection',
        'features', json_agg(ST_AsGeoJSON(clusters.*)::json)
    )
    FROM (
        SELECT
            id,
            building_count,
            -- No idea why ForceRHR doesn't help
            ST_ForceRHR(ST_Transform(geom, 4326)) AS geom
        FROM building_clusters
        ORDER BY building_count DESC
        LIMIT 1000
    ) clusters
    ;
EOF

# For some reason, the exported GeoJSON files do not follow the "right-hand
# rule" how to order the polygon nodes. Fix them using 'geojson-rewind'.
for file in data/*.geojson; do
	mv "$file" "$file.left"
	geojson-rewind "$file.left" > "$file"
	rm "$file.left"
done
