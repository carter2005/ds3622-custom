#
# Checking modules is loaded
#

echo -n "Loading module processor -> "
[ `/sbin/lsmod | grep -i processor | wc -l` -gt 0 ] && echo "Module processor loaded succesfully" || echo "Module processor is not loaded"
