#!/usr/bin/env python
#
#############################################################################
# AUTHOR(S): Stefan Blumentrath
# PURPOSE: Autocomplete species names entered in a custom fom in QGIS
# COPYRIGHT: (C) 2015 by the Stefan Blumentrath
#
# This program is free software under the GNU General Public
# License (>=v2).
#############################################################################
#
# This Python script implements an autocompleter in a custom
# QGIS form for species names based on an official list of 
# species names from Artsdatabanken. The latter is regularly
# (every sunday) updated.
#
# This autocompleter requires the field "latinn".
# This would have to be adjusted to the name of the 
# relevant field in other use cases.
# Furthermore, the SQL query which fetches the items 
# for the autocompleter is only set up for fungi,
# because the MATERIALIZED VIEW only contains fungi.
# In other cases this can easily be adjusted.
# 
# It also requires a OpenProject() Python macro 
# (./generate_autocompleter.py) loaded at the start of
# a QGIS project. This macro is used to cache the 
# completer items, so they are fetched from DB
# only once, which speeds up the GUI start.
#
# To do`s:
# - Implement validation of species names
#   (see: http://nathanw.net/2011/09/05/qgis-tips-custom-feature-forms-with-python-logic/)
# - Interaction with other information on the form (e.g. an option to enter norwegian names)
#   (solution: SIGNALs and SLOTs in Qt)

from PyQt4.QtCore import *
from PyQt4.QtGui import *
import generate_autocompleter

nameField = None
myDialog = None

def formOpen(dialog,layerid,featureid):
    global myDialog
    myDialog = dialog
    global nameField
    nameField = dialog.findChild(QLineEdit,"latinn")
    
    #Initiate completer
    completer = QCompleter()
    nameField.setCompleter(completer)
    
	#Add data to Qt Model / QCompleter
    model = QStringListModel()
    model.setStringList(generate_autocompleter.completition_items)
    completer.setModel(model)
