#
# Checking modules is loaded
#

echo -n "Loading module cpufreq_performance -> "
[ `/sbin/lsmod | grep -i cpufreq_performance | wc -l` -gt 0 ] && echo "Module cpufreq_performance loaded succesfully" || echo "Module cpufreq_performance is not loaded"
