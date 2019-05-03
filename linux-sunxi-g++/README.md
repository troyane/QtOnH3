# Project setup

![](https://gitlab.com/OP1Q-all/OP1Q-misc/raw/master/pics/kit_setup.png)


# Build result

Current errors:

```
10:27:03: Starting: "/usr/bin/make" 
/home/tro/NanoPi/buildroot_sysroot/bin/arm-buildroot-linux-gnueabihf-g++ -c -pipe -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Ofast -g2 --sysroot=/arm-buildroot-linux-gnueabihf/sysroot -g -std=gnu++1y -Werror -Wall -W -D_REENTRANT -fPIC -DGIT_VERSION=\"0.0.1\" -DAPP_NAME=\"OP1Q\" -DFULL_APP_VERSION=\"OP1Q_0.0.1\" -DQT_DEPRECATED_WARNINGS -DNANOPI -DQT_QML_DEBUG -DQT_QUICK_LIB -DQT_GUI_LIB -DQT_QML_LIB -DQT_NETWORK_LIB -DQT_CORE_LIB -I../op1q -I. -I../op1q/src -I../op1q/thirdparty -I/usr/local/include -I/usr/include -I/usr/include/KF5/Solid -I/arm-buildroot-linux-gnueabihf/sysroot/usr/include/qt5 -I/arm-buildroot-linux-gnueabihf/sysroot/usr/include/qt5/QtQuick -I/arm-buildroot-linux-gnueabihf/sysroot/usr/include/qt5/QtGui -I/arm-buildroot-linux-gnueabihf/sysroot/usr/include/qt5/QtQml -I/arm-buildroot-linux-gnueabihf/sysroot/usr/include/qt5/QtNetwork -I/arm-buildroot-linux-gnueabihf/sysroot/usr/include/qt5/QtCore -I. -I/home/tro/NanoPi/buildroot_sysroot/mkspecs/devices/linux-buildroot-g++ -o main.o ../op1q/main.cpp
arm-buildroot-linux-gnueabihf-g++: WARNING: unsafe header/library path used in cross-compilation: '-I/usr/local/include'
arm-buildroot-linux-gnueabihf-g++: WARNING: unsafe header/library path used in cross-compilation: '-I/usr/include'
arm-buildroot-linux-gnueabihf-g++: WARNING: unsafe header/library path used in cross-compilation: '-I/usr/include/KF5/Solid'
In file included from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/ext/string_conversions.h:41:0,
                 from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/bits/basic_string.h:5417,
                 from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/string:52,
                 from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/stdexcept:39,
                 from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/array:39,
                 from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/tuple:39,
                 from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/bits/stl_map.h:63,
                 from /home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/map:61,
                 from ../op1q/src/prerequisites.h:8,
                 from ../op1q/src/usbdevicebinder.h:3,
                 from ../op1q/src/op1qapplication.h:3,
                 from ../op1q/main.cpp:1:
/home/tro/NanoPi/buildroot_sysroot/arm-buildroot-linux-gnueabihf/include/c++/6.4.0/cstdlib:75:25: fatal error: stdlib.h: No such file or directory
 #include_next <stdlib.h>
                         ^
compilation terminated.
Makefile:597: recipe for target 'main.o' failed
make: *** [main.o] Error 1
10:27:03: The process "/usr/bin/make" exited with code 2.
Error while building/deploying project op1q (kit: Buildroot Qt 5.11.1 for NanoPi)
When executing step "Make"
10:27:03: Elapsed time: 00:00.
```
