# Building UT

This process does not build [Ubuntu Touch](https://ubports.com/)! An Android compatibility image is installed along 
with a prebuilt Ubuntu Touch filesystem to create a running Ubuntu Touch system. It relies on
the [Repo](https://source.android.com/setup/develop#repo) command to initialize and
download all the dependencies. Repo unifies Git repositories when necessary, performs uploads to the Gerrit revision 
control system, and automates parts of the Android development workflow.

## Known build dependencies:

```
sudo dpkg --add-architecture i386 && sudo apt update
sudo apt install schedtool gcc g++ g++-multilib zlib1g-dev:i386 \
     zip libxml2-utils bc python-launchpadlib repo
```

## Clone and sync steps

Create a directory for your UT source:

```
mkdir ~/ubports
cd ~/ubports
```

Then initialize the repository and download the source:

```
repo init -u https://github.com/legacyUT/android -b ubp-5.1-allthefixings --depth=1
repo sync -j 10 -c --force-sync
```

## Build the source

With the sources downloaded, we need to set up our environment and build the images.

```
export USE_CCACHE=1
source build/envsetup.sh
lunch aosp_hammerhead-userdebug
time make clobber
time make -j 32
```
