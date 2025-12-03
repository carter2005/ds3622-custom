#
# Checking modules is loaded
#

echo -n "Loading module r8125 -> "
[ `/sbin/lsmod | grep -i r8125 | wc -l` -gt 0 ] && echo "Module r8125 loaded succesfully" || echo "Module r8125 is not loaded"
