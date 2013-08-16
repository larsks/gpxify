What's all this, then?
======================

I wanted to make data from NOAA ENC charts available on my handheld
GPS.  This is what I came up with after looking for a way to automate
the extraction and conversion process.  It works great for "ponctual
data" (data consisting of points), but I haven't yet found a way to
automate the conversion of polygon data to multiline (you can do this
manually in QGIS).

Currently, this relies on `ogr2ogr`, `ogr2vrt`, and `ogrinfo`, which
are part of the `gdal` Python module.

I postprocess the output from `ogr2ogr` using a short Python script to
(a) sequentially number waypoints (we can't use the names from the
NOAA charts because they're too long), and (b) set waypoint symbols.


