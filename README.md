# Rclone and Nextcloud

Quick evalation to check if `rclone` is a suitable tool to sync files between the local filesystem and Nextcloud. Covers setup and basic use cases.

# Introduction

Rclone *("rsync for cloud storage")* is an open source command line program to sync files and directories to and from different cloud storage providers. Rclone is written in Go and available as a binary and also as a docker image.

[Website](https://rclone.org) |
[Documentation](https://rclone.org/docs/) |
[Installation](https://rclone.org/install/) |
[Forum](https://forum.rclone.org/) |
[Github](https://github.com/rclone/rclone)

Rclone supports Nextcloud via the [WebDAV](https://rclone.org/webdav/#nextcloud) backend provider.
The following install and sync tests     are done based on the newest version of rclone - 1.50.2.

# Configuration

Configuration is either be done via using a configuration file or also via environment variables.

## Via a configuration file

Multiple backends can be specified. 

For *Nextcloud* the `type` needs to be `webdav`, `vendor` set to `nextcloud` and the remote `url` needs to have appended the following path: `/remote.php/webdav/`.


```bash
[MEDTST]
type = webdav
url = https://partner.medneo.info/remote.php/webdav/
vendor = nextcloud
user = ingo.feulner
# provide password by running 'rclone obscure <password>'
pass = <redacted>
```

## Via environment variables

Rclone can be configured entirely using environment variables. These can be used to set defaults for options or config file entries.
To find the name of the environment variable you need to set to be used for a config entry, take `RCLONE_CONFIG_` + `<name of remote>` + _ + name of config file option and make it all uppercase.

The above shown config file results in setting the following environment variables:

```bash
export RCLONE_CONFIG_MEDTST_TYPE=webdav
export RCLONE_CONFIG_MEDTST_URL=https://partner.medneo.info/remote.php/webdav/
export RCLONE_CONFIG_MEDTST_VENDOR=nextcloud
export RCLONE_CONFIG_MEDTST_USER=ingo.feulner
export RCLONE_CONFIG_MEDTST_PASS=<redacted>
```

Can then be used either in a shell via `source <env-file>` or when using docker with `docker run --env-file <env-file>` (without the `export` before each variable).

Test configuration by running e.g.
```bash
rclone ls MEDTST:/ # lists a remote
```
or
```bash
# see provided Dockerfile, build with docker build .
docker run --env-file env_file.sh <rclone-imageid> ls MEDTST:/ # lists a remote
```


# Syncing

Syncing is done via the command [sync](https://rclone.org/commands/rclone_sync/).

```
rclone sync source:path dest:path [flags]
```

Make source and dest identical, modifying destination only.

## Synopsis

Rclone syncs the source to the destination, changing the destination only (one-way sync). Doesn’t transfer unchanged files, testing by size and modification time or MD5SUM. 
Destination is updated to match source, including **deleting** files if necessary.

Important: Since this can cause data loss, test first with the `--dry-run` flag to see exactly what would be copied and deleted.

## Concrete example

### Sync from remote src to local destination

```bash
# when using a config file
rclone --config rclone.conf -P --use-server-modtime sync "MEDTST:/Documents" "temp/"

# with environment variables (see above) set
rclone -P --use-server-modtime sync "MEDTST:/Documents" "temp/"

# Output
Transferred:   	    2.487M / 2.487 MBytes, 100%, 1.172 MBytes/s, ETA 0s
Errors:                 0
Checks:                 0 / 0, -
Transferred:            3 / 3, 100%
Elapsed time:        2.1s

# second run (no changes obviously)
rclone -P --use-server-modtime sync "MEDTST:/Documents" "temp/"

Transferred:   	         0 / 0 Bytes, -, 0 Bytes/s, ETA -
Errors:                 0
Checks:                 3 / 3, 100%
Transferred:            0 / 0, -
Elapsed time:          0s

```

* `--config` allows to specifiy another file to be be used for configuration
* `-P` displays the progress in the commandline
* `--use-server-modtime` uses server modified time instead of object metadata

### Sync from local src to remote destination
```bash
# with environment variables (see above) set
rclone -P --use-server-modtime sync "./temp/" "MEDTST:/Documents" 
```


## Findings

* `rclone` doesn't sync directory date and times
* symlinks will be ignored (or copied, if `--copy-links` / `-L` is specified)

