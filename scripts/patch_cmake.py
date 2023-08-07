#Small script to patch our cmake download locations
#Usage: python patch_cmake.py <file>

import sys

input = sys.argv[1]

print("Patching "+input+" to use spotify for downloads again...")

f = open(input, "r")
result = ""
for x in f:
  result += x.replace("https://cache-redirector.jetbrains.com/intellij-jbr/", "https://cef-builds.spotifycdn.com/")

f.close()

f = open(input, "w")
f.write(result)
f.close()

print("Done.")
