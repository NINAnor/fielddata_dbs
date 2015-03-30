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
# This implementation of the autocompleter requires the field "latinn".
# This would have to be adjusted to the name of the 
# relevant field in other use cases.
# 
# It also requires that ./generate_autocompleter.py is run as a 
# OpenProject() Python macro at the start of a QGIS project, 
# which caches species names into a global variable. 
#
# The autocompleter can be added to a TextEdit (QLineEdit) widget
# by referencing it as From init function.
# The latter is achieved by saving this script in the project folder
# and referencing it as "species_autocompleter.formOpen" in the 
# "Fields" tab of the relevant layer in QGIS.
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

    # Disconnect the signal that QGIS has wired up for the dialog to the button box.
    buttonBox.accepted.disconnect(myDialog.accept)
 
    # Wire up our own signals.
    buttonBox.accepted.connect(validate)
    buttonBox.rejected.connect(myDialog.reject)
 
def validate():
  # Make sure that the name field isn't empty.
    if not nameField.text().length() > 0:
        msgBox = QMessageBox()
        msgBox.setText("Name field can not be null.")
        msgBox.exec_()
	elif not nameField.text() in completition_items:
        msgBox = QMessageBox()
        msgBox.setText("Name field can not be null.")
        msgBox.exec_()
    else:
        # Return the form as accpeted to QGIS.
        myDialog.accept()
