#!/bin/bash

flutter build macos --release
#brew install create-dmg
create-dmg  "build/macos/Build/Products/Release/上肢运动-认知协同康复训练及评估系统.app"