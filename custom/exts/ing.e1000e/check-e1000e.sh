#
# Checking modules is loaded
#

echo -n "Loading module e1000e -> "
[ `/sbin/lsmod | grep -i e1000e | wc -l` -gt 0 ] && echo "Module e1000e loaded succesfully" || echo "Module e1000e is not loaded"
