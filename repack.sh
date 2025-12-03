#!/bin/bash

cd custom

# git ignore blank folder
(find .) | cpio --owner root:root -oH newc | lzma -8 > ../custom.gz
