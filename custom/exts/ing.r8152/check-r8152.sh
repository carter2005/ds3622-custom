#
# Checking modules is loaded
#

echo -n "Loading module r8152 -> "
[ `/sbin/lsmod | grep -i r8152 | wc -l` -gt 0 ] && echo "Module r8152 loaded succesfully" || echo "Module r8152 is not loaded"
