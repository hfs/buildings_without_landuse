\echo >>> Filter :"building" without :"landuse"
DROP TABLE IF EXISTS :"buildings_without_landuse";
CREATE TABLE :"buildings_without_landuse" AS
SELECT b.*
FROM :"building" b LEFT JOIN :"landuse" l
ON ST_Intersects(l.geom, b.geom)
WHERE l.area_id IS NULL
;

\echo >>> Cluster buildings, keep only bigger clusters
DROP TABLE IF EXISTS :"building_clusters";
CREATE TABLE :"building_clusters" AS
SELECT
	id,
	ST_ConvexHull(ST_Collect(geom)) AS geom,
	COUNT(id) AS building_count
FROM (
	SELECT
		ST_ClusterDBSCAN(geom, eps := 100, minpoints := 10) over () AS id, geom
	FROM :"buildings_without_landuse"
) clustr
WHERE id IS NOT NULL
GROUP BY id
;
ALTER TABLE :"building_clusters" ALTER COLUMN geom TYPE geometry(Polygon, 3857);
