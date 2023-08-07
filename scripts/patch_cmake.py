#Small script to patch our cmake download locations
#Usage: python patch_cmake.py <file>

import sys

input = sys.argv[1]

print("Patching "+input+"...")

f = open(input, "r")
result = ""
for x in f:
  result += x.replace("https://cache-redirector.jetbrains.com/intellij-jbr/", "https://cef-builds.spotifycdn.com/") \
      .replace("_minimal", "") \
      .replace(".zip", ".tar.bz2") \
      .replace(".checksum", ".sha1") \
      .replace("SHA256", "SHA1") \
      .replace("x86_64", "amd64")

f.close()

f = open(input, "w")
f.write(result)
f.close()

print("Done.")
