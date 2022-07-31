#/bin/bash

# copy up to date compiled programs to deb build dir
rm -R ./work_area > /dev/null 2>&1
mkdir work_area
mkdir work_area/etc
mkdir work_area/DEBIAN
cp -R ../update_bad_hosts ./work_area/etc/
chmod 0755 ./work_area/etc/
chmod 0755 ./work_area/etc/update_bad_hosts/
chmod +x ./work_area/etc/update_bad_hosts/*.sh

# update version number in deb control file
version=""
if [ -e "version" ]; then
 version=$(cat "version" | tr -d "\r" | tr -d "\n")
fi
if [ -z "$version" ]; then
 version="0.1"
fi
version=$(echo "$version + 0.1" | bc -l)
version=$(printf "%4.1f" "$version")
echo -n "$version" > version
echo "Package: update-bad-hosts" > ./work_area/DEBIAN/control
echo "Version: $version" >> ./work_area/DEBIAN/control
echo "Maintainer: James Harwood" >> ./work_area/DEBIAN/control
echo "Architecture: all" >> ./work_area/DEBIAN/control
echo "Depends: bash | systemd | coreutils | gawk | sed | wget" >> ./work_area/DEBIAN/control
echo "Description: https://github.com/jamesharwood/update_bad_hosts" >> ./work_area/DEBIAN/control

# make post install script
echo "#!/bin/bash" > ./work_area/DEBIAN/postinst
echo "set -e" >> ./work_area/DEBIAN/postinst
echo "systemctl enable /etc/update_bad_hosts/update_bad_hosts.service" >> ./work_area/DEBIAN/postinst
echo "cd /etc/update_bad_hosts" >> ./work_area/DEBIAN/postinst
echo "./update_bad_hosts.sh" >> ./work_area/DEBIAN/postinst
echo "systemctl start update_bad_hosts.service" >> ./work_area/DEBIAN/postinst
chmod +x ./work_area/DEBIAN/postinst

# make deb file
filename=$(printf "../update-bad-hosts_%1.1f_all.deb" "$version")
dpkg-deb --build --root-owner-group work_area "$filename"

