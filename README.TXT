                      -----------------------------------
                      |      DOORS NX VERSION 1.51      |
                      |                                 |
                      |                                 |
                      |            README               |
                      |                                 |  
                      -----------------------------------

Copyright (C) 2021 David Badiei

System requirements
=====================
CPU - Intel 386 or higher (math coprocessor required)
RAM - 1MB memory or higher
Disk requirements - flash drive or 1.44MB HD floppy disk required
Graphics - VBE 2.0 compatible video card
Keyboard - PS/2 keyboard or keyboard that emulates a PS/2 interface
Mouse - PS/2 mouse or mouse that emulates a PS/2 interface
You will also need software that can image the boot medium with the DavidDOS
image. I personally used the HxD hex editor for this purpose.

Steps to setup Doors NX
=========================
1. Insert the boot medium into the computer.
2. Image the boot medium with the Doors NX image using the imaging software of
your choice.
3. Insert the boot medium into the computer while it is off.
4. At bootup, press F12 or whatever key that gets you into the boot options
for your computer.
5. Select the DavidDOS medium for the boot options
6. If you followed the steps correctly you are now running Doors NX

Software I used to make Doors NX
=====================================
NASM - A free assembler
Microsoft Visual Studio - Code editor
Imdisk Virtual Disk driver - Allowed me to mount a virtual disk into Windows
VMware Workstation - Virtual machine software I used during development
HxD hex editor - Imaging and debugging

Extra thanks to Mike Saunders and Mikestylz as I used some of their assets
for the development of Doors
