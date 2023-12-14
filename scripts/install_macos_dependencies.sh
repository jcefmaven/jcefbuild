#!/bin/bash

brew install ninja
python -m venv .venv
source .venv/bin/activate
pip install --ignore-installed six
