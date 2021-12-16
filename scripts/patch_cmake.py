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
    result += x

f.close()
p.close()

#Replace cmake version, as 3.19 is not really needed
result.replace("3.19", "3.18")

f = open(input, "w")
f.write(result)
f.close()

print("Done.")
