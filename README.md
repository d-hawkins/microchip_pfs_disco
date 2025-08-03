# Microchip PolarFire SoC Discovery Kit Tutorial

8/1/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

This repository contains a Microchip PolarFire SoC Discovery Kit tutorial.

Directory           | Contents
--------------------|-----------
doc                 | Tutorial document
designs             | Libero SoC designs
ip                  | Intellectual Property (IP)
tcl                 | Tcl scripts
references          | Reference documentation

## Resources

Document                    | Link
----------------------------|-----------------------
Discovery Kit web page      | https://www.microchip.com/en-us/development-tool/mpfs-disco-kit
AN5165 FIR filter example   | https://www.microchip.com/en-us/application-notes/an5165
Reference hardware design   | https://github.com/polarfire-soc/polarfire-soc-discovery-kit-reference-design
Bare-metal software designs | https://github.com/polarfire-soc/polarfire-soc-bare-metal-examples

## Git LFS Installation

This repository was created using the github web interface, then checked out using Windows 10 WSL, and git LFS was installed using

~~~
$ git clone git@github.com:d-hawkins/microchip_pfs_disco.git
$ cd microchip_pfs_disco/
$ git lfs install
~~~

The .gitattributes file from another repo was then copied to this repo, and that file checked in.

~~~
$ git add .gitattributes
$ git commit -m "Git LFS tracking" .gitattributes
$ git push
~~~

The .gitattributes file contains file extension patterns for the majority of binary file types that could be checked into the repo (additional patterns can be added as needed).

