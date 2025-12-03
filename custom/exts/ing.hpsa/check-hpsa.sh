#
# Checking modules is loaded
#

echo -n "Loading module hpsa -> "
[ `/sbin/lsmod | grep -i hpsa | wc -l` -gt 0 ] && echo "Module hpsa loaded succesfully" || echo "Module hpsa is not loaded"
