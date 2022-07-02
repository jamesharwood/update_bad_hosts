# update_bad_hosts
Performs daily update of blocked advertising/tracker hosts in /etc/hosts from multiple sources

<B>REQUIRED PACKAGES</B> (Tested on Debian Bullseye)<BR>
systemd, bash, md5sum, awk, sed, sort<BR>
<BR>
<B>INSTALL</B><BR>
Download update_bad_hosts folder to /etc<BR>
chmod +x /etc/update_bad_hosts/*.sh<BR>
chown -R root:root /etc/update_bad_hosts<BR>
systemctl enable /etc/update_bad_hosts/update_bad_hosts.service<BR>
systemctl start update_bad_hosts.service<BR>
Wait 5 minutes before first entries appear in log file.<BR>
<BR>
<B>CONFIGURATION</B><BR>
Log is at /var/log/update_bad_hosts.log<BR>
<BR>
To add/remove blocklist sources edit /etc/update_bad_hosts/list-blocklists.txt<BR>
<BR>
<B>OVERVIEW</B><BR>
Service performs daily download of multiple host blocklists, aggregates them, ensures no funny business in the lists (Makes sure all entries point to 0.0.0.0), removes duplicates and updates /etc/hosts<BR>
<BR>
Download list in this git contains the following which seem to be updated regularly:<BR>
https://hosts.anudeep.me/mirror/adservers.txt<BR>
https://hosts.anudeep.me/mirror/CoinMiner.txt<BR>
https://github.com/notracking/hosts-blocklists/raw/master/hostnames.txt<BR>
https://www.netguard.me/hosts<BR>
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts;showintro=0<BR>
https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/trackers.hosts?inline=false<BR>
https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/malware.hosts?inline=false<BR>
