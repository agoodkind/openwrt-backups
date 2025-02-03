#!/bin/sh

echo "$(date -Iseconds) Starting..."

mkdir -p /tmp/openwrt-backups
rm -rf /tmp/openwrt-backups
mkdir -p /tmp/openwrt-backups
cp -r /home/agoodkind/openwrt-backups/.git /tmp/openwrt-backups/
cd /tmp/openwrt-backups
git pull

sysupgrade -b backup.tar.gz
tar xfz backup.tar.gz
mkdir -p backup-expanded
mv etc backup-expanded/etc

mkdir -p full-sys
cp -rx / full-sys/

# Define the files to check
FILES="etc backup.tar.gz"

# Check if any file has changes
CHANGES_DETECTED=0

# Check each file for changes
for F in $FILES; do
	echo "$(date -Iseconds) Checking $F"
	git diff --quiet "$F"
	if [ $? -ne 0 ]; then
		echo "$(date -Iseconds) Changes detected in $F"
		CHANGES_DETECTED=1
	fi
done

# Perform an action if any file has changes
if [ $CHANGES_DETECTED -eq 1 ]; then
	echo "$(date -Iseconds) At least one file has changes. Pushing to git."
	git commit -a -m "Update for $(date)"
	git push --quiet
else
	echo "$(date -Iseconds) No changes detected in any file."
fi
