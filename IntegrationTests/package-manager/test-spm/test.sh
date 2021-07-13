#! /usr/bin/env bash

set -euxo pipefail

swift package clean

swift run MyApp
