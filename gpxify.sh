#!/bin/bash

: ${OGR2VRT:=ogr2vrt}
: ${OGR2OGR:=ogr2ogr}
: ${OGRINFO:=ogrinfo}

ADD_SYMBOL_XSL=${0%/*}/add_symbol.xslt

BEACONS="BCNCAR|BCNISD|BCNLAT|BCNSAW|BCNSPP"
BUOYS="BOYCAR|BOYINB|BOYISD|BOYLAT|BOYSAW|BOYSPP"
LIGHTS="LIGHTS"

tmpdir=$(mktemp -d -t gpxXXXXXX)
trap 'rm -rf $tmpdir' EXIT INT HUP

# usage: gen_gpx map suffix symbol
gen_gpx () {
	local map=$1
	local suffix=$2
	local symbol=$3
	local objects=$4

	rm -f $tmpdir/stage1 $tmpdir/stage2 $map-$suffix.gpx

	$OGR2OGR \
		-f GPX $tmpdir/stage1 -skipfailures \
		-dsco GPX_USE_EXTENSIONS=YES $tmpdir/map.vrt \
		$($OGRINFO $map.000 2>/dev/null |
			awk '/^[0-9]/ {print $2}' | egrep "$objects")

	sed '
	/<\/wpt>/ i\
	<sym>'"$symbol"'</sym>
	' $tmpdir/stage1 > $map-$suffix.gpx
}

for path in "$@"; do
	map=${path##*/}
(
	cd $path
	$OGR2VRT $map.000 $tmpdir/map.vrt.in
	sed '
		/OBJNAM/ s/OBJNAM/name/
		/INFORM/ s/INFORM/desc/
	' $tmpdir/map.vrt.in > $tmpdir/map.vrt

	gen_gpx $map beacons "Navaid, Amber" $BEACONS
	gen_gpx $map lights Light $LIGHTS
	gen_gpx $map buoys "Buoy, White" $BUOYS

	gpsbabel -i gpx -f $map-beacons.gpx -f $map-lights.gpx -f $map-buoys.gpx \
		-o gpx -F $map.gpx
)
done

