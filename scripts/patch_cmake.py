#Small script to patch CMakeLists.txt files with custom build options
#Will replace file contents between two markers ("Determine the platform"
#and "Add this project's cmake")
#Usage: python patch_cmake.py <input> <patch>

import sys

input = sys.argv[1]
patch = sys.argv[2]

print("Patching "+input+" to accept further build architectures...")

f = open(input, "r")
p = open(patch, "r")
result = ""
inpatch = False
for x in f:
  if x.startswith("# Determine the platform"):
    inpatch = True
    for y in p:
      result += y
  elif x.startswith("# Add this project's cmake"):
    inpatch = False
  if inpatch == False:
    #Patch minimum cmake version to not break our builds on linux
    if x.startswith("cmake_minimum_required"):
      result += "cmake_minimum_required(VERSION 3.13)\n"
    else:
      result += x

f.close()
p.close()

f = open(input, "w")
f.write(result)
f.close()

print("Done.")
