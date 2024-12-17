#!/bin/bash

git clone https://github.com/truenas/zettarepl.git

python3 -m venv .env

source .env/bin/activate

cd zettarepl/

pip install .

