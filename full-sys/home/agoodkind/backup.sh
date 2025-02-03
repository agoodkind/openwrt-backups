#!/bin/sh

set -e 1
set -x

echo "$(date -Iseconds) Starting..."

rm -rf /tmp/openwrt-backups
cd /tmp

git clone --depth=1 git@github.com:agoodkind/openwrt-backups.git --quiet
cd openwrt-backups

sysupgrade -b backup.tar.gz
tar xfz backup.tar.gz
mkdir -p backup-expanded
mv etc backup-expanded/etc

mkdir -p full-sys
PATHS_TO_COPY="/etc /usr /home /root /www"
for P in $PATHS_TO_COPY; do
	echo "$(date -Iseconds) Copying $P"
	cp -r $P /tmp/openwrt-backups/full-sys/
done

# Define the files to check
FILES="backup-expanded/etc full-sys backup.tar.gz"

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
