#! /usr/bin/env bash

case $PACKAGE_MANAGER in
  
  USE_SPM)
    cd test-spm
    bash test.sh 
    ;;
  
  USE_COCOAPODS)
    cd test-cocoapods
    bash test.sh
    ;;
  
  USE_CARTHAGE)
    cd test-carthage
    bash test.sh
    ;;
  
  *)
    echo 'noop'
    ;;
esac
