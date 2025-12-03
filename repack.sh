#!/bin/bash

cd custom

# git ignore blank folder
mkdir -p usr/sbin
(find .) | cpio --owner root:root -oH newc | lzma -8 > ../custom.gz
