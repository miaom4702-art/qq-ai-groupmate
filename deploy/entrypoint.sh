#!/bin/sh
set -eu
nb orm upgrade
exec python bot.py
