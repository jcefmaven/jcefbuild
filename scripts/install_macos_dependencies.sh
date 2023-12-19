#!/bin/bash

PYTHON=/Library/Frameworks/Python.framework/Versions/Current/bin/python

brew install ninja
"$PYTHON" -m pip install --ignore-installed six

"$PYTHON" -m pip list
echo "from six.moves import configparser" | "$PYTHON" && echo "Success importing stuff from six moves python module"
