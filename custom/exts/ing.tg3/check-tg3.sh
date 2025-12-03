#
# Checking modules is loaded
#

echo -n "Loading module libphy -> "
[ `/sbin/lsmod | grep -i libphy | wc -l` -gt 0 ] && echo "Module libphy loaded succesfully" || echo "Module libphy is not loaded"
echo -n "Loading module tg3 -> "
[ `/sbin/lsmod | grep -i tg3 | wc -l` -gt 0 ] && echo "Module tg3 loaded succesfully" || echo "Module tg3 is not loaded"
