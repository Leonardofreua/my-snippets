### Count how many lines a java project has

```bash
find . -name '*.java' ! -name "Q*.java" ! -path "./target/*" -type f -print0 | xargs -0 cat | wc -l
```

### Mounting and Repairing a FAT32 External HDD on Ubuntu 24.04

This guide shows how to safely check, repair, and mount a FAT32 external hard drive that was formatted in a previous Ubuntu version.

1. Identify the Disk

```bash
lsblk -f /dev/sdc # example
```

2. Check the Filesystem (Read-Only)

```bash
sudo dosfsck -n /dev/sdc
```

Explanation:

* dosfsck checks FAT filesystems.
* -n means no changes, only report errors.
* This allows you to see if the filesystem has issues without modifying it.

3. Repair the Filesystem Interactively

```bash
sudo dosfsck -r /dev/sdc
```

Explanation:

`-r` = interactive repair, asks before fixing each problem.

Fixes issues like the dirty bit or boot sector mismatch.

* Remove dirty bit → 1
* Write changes → 1
* Fix boot sector if needed → 1 or 2

4. Mount the Disk Manually

```bash
sudo mount /dev/sdc /mnt
```

Explanation:

* Mounts the FAT32 disk to /mnt.
* If the disk was already auto-mounted, you might see an “already mounted” message.

5. Verify Mount Point

```bash
mount | grep sdc
lsblk -f /dev/sdc
```

Explanation:

* Confirms that the disk is mounted and shows the mount point.
* Ensures you know where to access your files (e.g., /mnt).