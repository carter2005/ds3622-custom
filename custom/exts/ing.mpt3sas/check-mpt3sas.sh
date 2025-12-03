#
# Checking modules is loaded
#

echo -n "Loading module mpt3sas -> "
[ `/sbin/lsmod | grep -i mpt3sas | wc -l` -gt 0 ] && echo "Module mpt3sas loaded succesfully" || echo "Module mpt3sas is not loaded"
