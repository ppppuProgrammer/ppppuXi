#!python3
# This script should only be executed by flashdevelop's post build command line.
#Purpose of this script is to create a copy of the latest swf built by flashdevelop and indicate the build properties used.
#Script expects to be executed from the projects main directory and for this directory to have a src folder which contains a file called Version.as that holds build data.
# Takes these additional arguments: build output path, built swf name, build config (release/debug), time stamp (as a failsafe if Version.as is not found) 
from pathlib import Path
import sys
import subprocess
import os
import shutil
from datetime import datetime
##const Strings
_s = '\"'

buildPath =  sys.argv[1] 
builtFileName = sys.argv[2]
buildConfig = sys.argv[3]
timeStamp = sys.argv[4]

buildRepositoryPath = buildPath + "/builds/"

versionFileFound = False

programVersion = ""
programBuildNumber = ""
programBuildDate = ""

versionLine = ""
buildNumberLine = ""
buildDateLine = ""
#First make sure the file that's being copied exists
##Get Directory this script is in, from which it'll go into the src folder
currentDirectory = Path(os.path.abspath(os.path.dirname(sys.argv[0])))
#print(currentDirectory)
srcPath = currentDirectory.joinpath("src")
#print(srcPath)
if srcPath.is_dir():
    versionFilePath = srcPath.joinpath("Version.as")
    #print(versionFilePath)
    if versionFilePath.exists() == True:
        with versionFilePath.open('r') as file:
            versionFileFound = True
            #Find the line with the version string
            content =  file.readlines()
            for line in content:
                if line.find("VERSION") != -1:
                    versionLine = line
                elif line.find("BUILDNUMBER") != -1:
                    buildNumberLine = line
                elif line.find("BUILDDATE") != -1:
                    buildDateLine = line

#public static const VERSION:String = "0.1.0 Build 8";
#public static const BUILDDATE:String = "7/5/2016 6:57 PM";
if(len(versionLine) > 0 and len(buildDateLine) > 0):
    #print (versionLine)
    programVersion = versionLine[versionLine.find("\"")+1:versionLine.rfind("\"")]
    programVersion = programVersion.replace(".", "-")
    #print(programVersion)
    programBuildNumber = buildNumberLine[buildNumberLine.find("\"")+1:buildNumberLine.rfind("\"")]
    #print(programBuildNumber)
    #builtInPM = true if (buildDateLine.find("PM") > -1) else false
    #hour = int(buildDateLine[buildDateLine.find(" ")+1:buildDateLine.rfind(":")])
    #if builtInPM:
    #    hour += 12
    #    buildDateLine = 
    buildDateLine = buildDateLine[buildDateLine.find("\"")+1:buildDateLine.rfind("\"")]
    
    #print(buildDateLine)
    buildDate = datetime.strptime(buildDateLine, '%m/%d/%Y %I:%M %p').strftime('%Y%m%d%H%M')
    #print(buildDate)

copyFileName = ""

fileExtension = builtFileName[(builtFileName.rfind(".")):]
fileName = builtFileName[:(builtFileName.rfind("."))]
if versionFileFound is True:
    copyFileName = fileName + "_Build" + programBuildNumber + "_" + buildDate + "_v" + programVersion + "_" + buildConfig + fileExtension
else:
    #Use the time stamp as a fallback for missing Version data.
    copyFileName = fileName + "_" + datetime.strptime(timeStamp, '%m/%d/%Y %I:%M %p').strftime('%Y%m%d%H%M') + "_" + buildConfig + fileExtension
#print(buildPath +'/'+ builtFileName)
#print(buildPath +"/builds/"+ copyFileName)

if Path(buildRepositoryPath).exists() == False:
    #print(buildRepositoryPath)
    Path(buildRepositoryPath).mkdir()

shutil.copyfile(buildPath +'/'+ builtFileName, buildRepositoryPath + "/" + copyFileName)
sys.exit(0)
