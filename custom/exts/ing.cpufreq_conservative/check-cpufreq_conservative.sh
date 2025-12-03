#
# Checking modules is loaded
#

echo -n "Loading module cpufreq_conservative -> "
[ `/sbin/lsmod | grep -i cpufreq_conservative | wc -l` -gt 0 ] && echo "Module cpufreq_conservative loaded succesfully" || echo "Module cpufreq_conservative is not loaded"
