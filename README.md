# PM 2018 setup
This script installs the tools needed to write code to PM PCB, makes a makefile,
source code as example, a script to upload the code to microcontroller. The
program that uploads the code will be installed in current directory.

## Install
Move ```install.sh``` in the directory where you want bootloader files to be
located.

``` $ ./install.sh ```

This will create 3 files:
* ```main.c``` - sample code to run
* ```Makefile``` - contains rules for building the binary
* ```go.sh``` - script that will compile and upload the code to microcontroller

## Note
```go.sh``` might not work on *Bash for Windows 10*.
