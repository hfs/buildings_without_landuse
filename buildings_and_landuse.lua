osm2pgsql.srid = 3035

local tables = {}
-- inspect = require('inspect')

prefix = os.getenv("OSM2PGSQL_PREFIX") or ''

tables.landuse = osm2pgsql.define_area_table(prefix .. 'landuse', {
    { column = 'landuse', type = 'text' },
    { column = 'geom', type = 'geometry' },
})

tables.building = osm2pgsql.define_area_table(prefix .. 'building', {
    { column = 'building', type = 'text' },
    { column = 'geom', type = 'geometry' },
})

tables.administrative = osm2pgsql.define_area_table(prefix .. 'administrative', {
    { column = 'name', type = 'text' },
    { column = 'admin_level', type = 'text' },
    { column = 'geom', type = 'geometry' },
})

function get_landuse(tags)
    return tags.landuse or tags.amenity or tags.power or tags.man_made or
      tags.leisure or tags.police or tags.aeroway or tags['disused:aeroway'] or
      tags.place or tags.tourism
end

function osm2pgsql.process_way(object)
    tags = object.tags
    landuse = get_landuse(tags)
    if landuse then
        row = {
            geom = { create = 'area' },
            landuse = landuse
        }
        tables.landuse:add_row(row)
    end
    building_value = tags.building or tags['building:part'] or
        tags['abandoned:building'] or tags['demolished:building'] or
        tags['removed:building'] or tags['razed:building']
    if building_value then
        row = { geom = { create = 'area' }, building = building_value }
        tables.building:add_row(row)
    end
end

function osm2pgsql.process_relation(object)
    tags = object.tags
    landuse = get_landuse(tags)
    if tags.type == 'multipolygon' and landuse then
        row = {
            geom = { create = 'area' },
            landuse = landuse
        }
        tables.landuse:add_row(row)
    end
    building_value = tags.building or tags['building:part'] or
        tags['abandoned:building'] or tags['demolished:building'] or
        tags['removed:building'] or tags['razed:building']
    if tags.type == 'multipolygon' and building_value then
        row = { geom = { create = 'area' }, building = building_value }
        tables.building:add_row(row)
    end
    if tags.type == 'boundary' and tags.boundary == 'administrative' then
        row = {
            geom = { create = 'area' },
            name = tags.name,
            admin_level = tags.admin_level
        }
        tables.administrative:add_row(row)
    end
end

