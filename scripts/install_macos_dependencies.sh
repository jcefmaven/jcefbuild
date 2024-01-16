#!/bin/bash

PYTHON=python3

brew install ninja
"$PYTHON" -m pip install --ignore-installed six

"$PYTHON" -m pip list
echo "from six.moves import configparser" | "$PYTHON" && echo "Success importing stuff from six moves python module"
