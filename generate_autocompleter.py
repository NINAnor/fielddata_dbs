#!/usr/bin/env python
#
#############################################################################
# AUTHOR(S): Stefan Blumentrath
# PURPOSE: Load species names at project startup into a global variable in 
#          QGIS to feed species_autocompleter.py
# COPYRIGHT: (C) 2015 by the Stefan Blumentrath
#
# This program is free software under the GNU General Public
# License (>=v2).
#############################################################################
#
# This Python script is used as a openProject() Python macro in QGIS
# It fetches species names from the official list of
# species names from Artsdatabanken. The latter is regularly
# (every sunday) updated. And loads them into a global variable,
# which can be used by the form init function which implements the QCompleter.
#
# The SQL query is only set up for fungi,
# because the MATERIALIZED VIEW only contains fungi.
# In other cases this can easily be adjusted.
#
# The script has to be located in the project folder 
# and is referenced in the project 
# (Project -> Properties -> Macros) like this:
# def openProject():
#    import generate_completer
#    generate_completer.fetch_citems()
#
# Curretnly one has to set Settings->Options->Enable Macros
# to “Always”, or “Only this session” (with “Ask” (the default setting)
# the startup macro does not load, see: http://hub.qgis.org/issues/9523) 
#
from PyQt4.QtCore import *
from qgis.core import *
import psycopg2

def fetch_citems():
    
    global completition_items
    #Fetch data from DB to fill completer
    conn = psycopg2.connect("dbname='gisdata' user='postgjest' host='ninsrv16' password='gjestpost'")
    cur = conn.cursor()
    cur.execute("""SELECT scientificname FROM kls.l_artsliste WHERE finnesinorge = 'Ja'""")
    completition_items = []
    for row in cur.fetchall():
        completition_items.append(row[0])
