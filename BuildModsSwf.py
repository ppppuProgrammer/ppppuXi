#!python3
# This script should only be executed by flashdevelop's pre/post build command line
from pathlib import Path
import sys
import subprocess
import os
import shlex
##const Strings
_s = '\"'
compilerPath =  sys.argv[1] 
compilerOption = ' -compiler ' + _s + compilerPath + _s
extraFBDArgs = ' -notrace '
fdBuildExePath = _s + sys.argv[2] +_s
buildConfig = sys.argv[3]

##Functions
def RecursiveDirSearch(directory):
    for subDirIt in directory.iterdir():
        if subDirIt.is_dir():
           RecursiveDirSearch(subDirIt)
        elif subDirIt.is_file():
           fileName = subDirIt.name
           if fileName.find(".as3proj") != -1:
                filePath = _s + str(subDirIt.resolve()) + _s
                command = fdBuildExePath + compilerOption + " " + extraFBDArgs + filePath
                print(command)
                task = shlex.split(command)
                ret = subprocess.call(task)
                if ret != 0:
                    print("An error was encountered when compiling. All pending swf compilations were aborted.")
                    sys.exit(1)

#First test the build config. If it is debug then exit out
#print(buildConfig)
if buildConfig == "debug":
    sys.exit(0)
##Get Directory this script is in, from which it'll go into subdirectories
##and look for flashdevelop projects.
#currentDirectory = Path('.')
#currentDirectory = abspath(getsourcefile(lambda:0))
currentDirectory = Path(os.path.abspath(os.path.dirname(sys.argv[0])))
#print(currentDirectory)
for dirIt in currentDirectory.iterdir():
    if dirIt.is_dir(): ##check if the iterator is pointing to a folder
           RecursiveDirSearch(dirIt)

print("All mod swfs were successfully compiled.")
sys.exit(0)
