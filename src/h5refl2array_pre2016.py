# -*- coding: utf-8 -*-
"""
Created on Wed Jun 21 13:50:32 2017

@author: bhass
"""

def h5refl2array_pre2016(refl_filename):
    """h5refl2array reads in a NEON AOP reflectance hdf5 in the pre-2016 format
    and returns reflectance array, select metadata, and wavelength (nm) datasets.
    --------
    Parameters
        refl_filename -- full or relative path and name of reflectance hdf5 file
    --------
    Returns 
    --------
    reflArray:
        array of reflectance values
    metadata:
        dictionary containing the following metadata:
            ext_dict: dictionary of spatial extent 
            extent: array of spatial extent (xMin, xMax, yMin, yMax)
            mapInfo: string of map information 
            *noDataVal: 15000.0
            res: dictionary containing 'pixelWidth' and 'pixelHeight' values (floats)
            scaleFactor: 10000.0
            shape: tuple of reflectance shape (y, x, # of bands)
        * Asterixed values differ from the post 2016 reflectance files.
    wavelengths:
        Wavelengths values 
    --------
    This function applies to the NEON hdf5 format implemented in 2016, which 
    applies to data acquired in 2016 & 2017 as of June 2017. Data in earlier 
    NEON hdf5 format is expected to be re-processed after the 2017 flight season. 
    --------
    Example
    --------
    teakRefl, teakRefl_md, wavelengths = h5refl2array('Subset3NIS1_20130614_100459_atmcor.h5') """
    
def h5refl2array_pre2016(refl_filename): 
    hdf5_file = h5py.File(refl_filename,'r')
    #Extract the reflectance & wavelength datasets
    reflArray = hdf5_file['Reflectance']
    wavelengths = hdf5_file['wavelength'].value*1000 # 2015 are in um, convert to nm

    #Create dictionary containing relevant metadata information
    metadata = {}
    metadata['shape'] = reflArray.shape
    metadata['mapInfo'] = hdf5_file['map info'].value

    #Extract no data value & set no data value to NaN
    metadata['noDataVal'] = float(reflArray.attrs['data ignore value'])
    metadata['scaleFactor'] = float(reflArray.attrs['Scale Factor'])

    #Extract map information: spatial extent & resolution (pixel size)
    mapInfo_string = str(metadata['mapInfo']); 
    mapInfo_split = mapInfo_string.split(",")

    #Extract the resolution & convert to floating decimal number
    metadata['res'] = {}
    metadata['res']['pixelWidth'] = float(mapInfo_split[5])
    metadata['res']['pixelHeight'] = float(mapInfo_split[6])

    #Extract the upper left-hand corner coordinates from mapInfo
    xMin = float(mapInfo_split[3]) #convert from string to floating point number
    yMax = float(mapInfo_split[4])
    #Calculate the xMax and yMin values from the dimensions
    xMax = xMin + (metadata['shape'][1]*metadata['res']['pixelWidth']) #xMax = left edge + (# of columns * resolution)",
    yMin = yMax - (metadata['shape'][0]*metadata['res']['pixelHeight']) #yMin = top edge - (# of rows * resolution)",
    metadata['extent'] = (xMin,xMax,yMin,yMax) #useful format for plotting
    metadata['ext_dict'] = {}
    metadata['ext_dict']['xMin'] = xMin
    metadata['ext_dict']['xMax'] = xMax
    metadata['ext_dict']['yMin'] = yMin
    metadata['ext_dict']['yMax'] = yMax
    hdf5_file.close        
    
    return reflArray, metadata, wavelengths