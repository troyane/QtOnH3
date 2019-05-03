# Tools for Crosscompilation of Qt 5.12+ on H3 devices (like NanoPi Neo Air)

## One-in-all Build Control script
Rule everything from one file. Still in progress, but will do the job for you.

Idea behind this script is to do next (step by step):

1.  Create tmpfs.
2.  Use created tmpfs.
3.  Get Qt 5.12.2 sources, init repository.
4.  Do total clean to remove possible leftovers from previous configurations and/or builds.
5.  Copy Sunxi mkspecs to respective folder in Qt sources tree.
6.  Check if there is cross-compiler available (GCC Linaro 7.4.1).
7.  Sync sysroot of NPi with respective local host folder.
8.  Config Qt for the build.
9.  Make Qt & install it to separate folder.
10. Sync newly created files on host with NPi.

---

For each mentioned step there is respective option. Run `./build_control -h` to get help about all available options.

Here we have all steps described.

### `cd` to dir with script
`cd` to dir with script before running it.

### Create tmpfs to optimize build time
Use command `./build_control -t` -- this will create `tmpfs` folder.

For next script runs use `-a` option, `already created tmpfs`.

### Get toolchain

Recommended toolchain (right now) is `gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf`.
Refer to file `gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf` for instructions. 
Replace this file by respective folder with toolchain.

By the next script run it will detect if you have installed compiller, otherwise it will unpack 
it into respective folder.

### Get Qt

Use `./build_control -a -g` to get Qt. Hope everything will be fine.

### Do clean to be sure that everything is ok

Use `./build_control -a -c` to do clean.

### Copy Sunxi mkspecs

Use `./build_control -a -s` to copy Sunxi mkspecs to Qt tree. Do not forget to use this option with `-c`, 
otherwise previously copied mkspecs could be removed.

### Sync Pi's sysroot with host

Use `./build_control -a --npi2host` to sync NPi's sysroot with host.
This option expects that you have:
- your NPi at `nano.pi`. Edit your `/etc/hosts` to make it work.
- your NPi has `root` account, since it will try to use it.
- able to provide `root` password as it will be required.

Note, that this script will use `sysroot-relativelinks.py` to "normilize" all relative links in synced files.

### Configure Qt

Use `./build_control -a -q` to configure Qt.

### Make and install Qt

Use `./build_control -a -m` to make and install Qt. Please, refer to logs. Hope everything will be fine.

### Sync host's sysroot with Pi

Use `./build_control --host2pi` to sync your updated sysroot with Pi, so you'll have consistent environment.
This option expects that you have:
- your NPi at `nano.pi`. Edit your `/etc/hosts` to make it work.
- your NPi has `root` account, since it will try to use it.
- able to provide `root` password as it will be required.

Note, that your Qt distribution will be available at `/opt/qt512` on NPi. Good luck!

## Perfect world scenario

In perfect world you'll use this script with next arguments and all will work like a charm:
```
./build_control -t -g -c -s -q -m --npi2host --host2pi
```
And everything will be done and anyone will be happy.

---

In real world you need to use this script several times with different options to get what you need. Good luck!
