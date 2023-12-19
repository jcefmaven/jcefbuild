#!/bin/bash

brew install ninja
python3 -m pip install --ignore-installed six

/Library/Frameworks/Python.framework/Versions/Current/bin/python -m pip list
echo "import six.moves" | /Library/Frameworks/Python.framework/Versions/Current/bin/python
