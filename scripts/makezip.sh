cd $APPVEYOR_BUILD_FOLDER
ocaml setup.ml -configure
ocaml setup.ml -build
cp $APPVEYOR_BUILD_FOLDER/_build/src/vultc.native $APPVEYOR_BUILD_FOLDER/vultc.exe
7z a $APPVEYOR_BUILD_FOLDER/vult-win.zip $APPVEYOR_BUILD_FOLDER/vultc.exe $APPVEYOR_BUILD_FOLDER/runtime/vultin.c $APPVEYOR_BUILD_FOLDER/runtime/vultin.h
npm install vult -g
vultc --help