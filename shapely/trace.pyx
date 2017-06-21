# (C) British Crown Copyright 2011 - 2017, Met Office
#
# This file was part of cartopy.  It is now part of shapely
#
# Shapely is licensed under the BSD 3-clause "New" or "Revised" License

"""
This module pulls together Shapely and GEOS for faster geometry conversion.
"""

from libc.stdint cimport uintptr_t as ptr


cdef extern from "geos_c.h":
    ctypedef void *GEOSContextHandle_t
    ctypedef struct GEOSGeometry:
        pass


import shapely.geometry as sgeom
from shapely.geos import lgeos


cdef GEOSContextHandle_t get_geos_context_handle():
    cdef ptr handle = lgeos.geos_handle
    return <GEOSContextHandle_t>handle


cdef GEOSGeometry *geos_from_shapely(shapely_geom) except *:
    """Get the GEOS pointer from the given shapely geometry."""
    cdef ptr geos_geom = shapely_geom._geom
    return <GEOSGeometry *>geos_geom


cdef shapely_from_geos(GEOSGeometry *geom):
    """Turn the given GEOS geometry pointer into a shapely geometry."""
    # This is the "correct" way to do it...
    #   return geom_factory(<ptr>geom)
    # ... but it's quite slow, so we do it by hand.
    multi_line_string = sgeom.base.BaseGeometry()
    multi_line_string.__class__ = sgeom.MultiLineString
    multi_line_string.__geom__ = <ptr>geom
    multi_line_string.__parent__ = None
    multi_line_string._ndim = 2
    return multi_line_string
