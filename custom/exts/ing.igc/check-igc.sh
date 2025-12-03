#
# Checking modules is loaded
#

echo -n "Loading module igc -> "
[ `/sbin/lsmod | grep -i igc | wc -l` -gt 0 ] && echo "Module igc loaded succesfully" || echo "Module igc is not loaded"
