#!/bin/bash

if [ -f "$HOME/.gpxify" ]; then
	. "$HOME/.gpxify"
fi

: ${OGR2VRT:=ogr2vrt}
: ${OGR2OGR:=ogr2ogr}
: ${OGRINFO:=ogrinfo}

GPXIFYDIR=$(cd $(dirname $0); pwd)
FIXUP_GPX=$GPXIFYDIR/fixup_gpx.py

BEACONS="BCNCAR|BCNISD|BCNLAT|BCNSAW|BCNSPP"
BUOYS="BOYCAR|BOYINB|BOYISD|BOYLAT|BOYSAW|BOYSPP"
LIGHTS="LIGHTS"

tmpdir=$(mktemp -d -t gpxXXXXXX)
trap 'rm -rf $tmpdir' EXIT INT HUP

# usage: gen_gpx map suffix symbol
gen_gpx () {
	local map=$1
	local suffix=$2
	local wptprefix=$3
	local symbol=$4
	local objects=$5

	echo "+ Generating $suffix map from $map"

	rm -f $tmpdir/stage1 $tmpdir/stage2 $map-$suffix.gpx

	$OGR2OGR \
		-f GPX $tmpdir/stage1 -skipfailures \
		-dsco GPX_USE_EXTENSIONS=YES $tmpdir/map.vrt \
		$($OGRINFO $map.000 2>/dev/null |
			awk '/^[0-9]/ {print $2}' | egrep "$objects")

	$FIXUP_GPX -f "$wptprefix" -s "$symbol" < $tmpdir/stage1 > $map-$suffix.gpx
}

for path in "$@"; do
	map=${path##*/}
(
	cd $path || exit

	$OGR2VRT $map.000 $tmpdir/map.vrt.in
	sed '
		/OBJNAM/ s/OBJNAM/desc/
	' $tmpdir/map.vrt.in > $tmpdir/map.vrt

	gen_gpx $map beacons "BEACON%03d" "Navaid, Amber" $BEACONS
	gen_gpx $map lights "LIGHT%03d" Light $LIGHTS
	gen_gpx $map buoys "BUOY%03d" "Buoy, White" $BUOYS

	gpsbabel -i gpx -f $map-beacons.gpx -f $map-lights.gpx -f $map-buoys.gpx \
		-o gpx -F $map.gpx
)
done

