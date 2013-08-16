#!/usr/bin/python

import os
import sys
import argparse
from lxml import etree

gpx_ns_10='http://www.topografix.com/GPX/1/0'
gpx_ns_11='http://www.topografix.com/GPX/1/1'

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--gpxversion', '-g', default='1.1')
    p.add_argument('--format', '-f', default='WPT%03d')
    p.add_argument('--symbol', '-s', default='Waypoint')
    return p.parse_args()

def main():
    opts = parse_args()

    if opts.gpxversion == '1.0':
        gpx_ns = gpx_ns_10
    elif opts.gpxversion == '1.1':
        gpx_ns = gpx_ns_11

    namespaces = { 'gpx': gpx_ns }

    wpt_counter = 0
    doc = etree.parse(sys.stdin)
    for wpt in doc.xpath('//gpx:wpt', namespaces=namespaces):
        for ele_name in [ 'name', 'sym' ]:
            ele = wpt.find('{%s}%s' % (gpx_ns, ele_name))
            if ele is not None:
                wpt.remove(ele)

        name = etree.Element('{%s}name' % gpx_ns)
        name.text = opts.format % wpt_counter
        wpt.append(name)

        sym = etree.Element('{%s}sym' % gpx_ns)
        sym.text = opts.symbol
        wpt.append(sym)

        wpt_counter += 1

    print etree.tostring(doc, pretty_print=True)

if __name__ == '__main__':
    main()


