#!/usr/bin/env bash

echo "Environment:"
printenv | grep -E "^(BUILD|FLOW|NEOS|MYSQL).*"
