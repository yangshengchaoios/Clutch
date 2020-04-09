#!/usr/bin/env bash

cd "$PROJECT_DIR"
! [ -d build ] && mkdir build
cp "$BUILT_PRODUCTS_DIR/$EXECUTABLE_PATH" "build/"
codesign -fs- --entitlements 'Clutch/Clutch.entitlements' "build/$EXECUTABLE_NAME"
sshpass -p 'skyguard' ssh -p2222 root@localhost 'rm /usr/bin/Clutch'
sshpass -p 'skyguard' scp -P 2222 "${PROJECT_DIR}/build/${EXECUTABLE_NAME}" root@localhost:/usr/bin/Clutch
