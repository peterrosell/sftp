atmoz/sftp
==========

Easy to use SFTP ([SSH File Transfer Protocol](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)) server with [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH).

Usage
-----

- Define users as last arguments to `docker run`, one user per argument  
  (syntax: `user:pass[:[e|k]][:[uid][:gid]][:homedir]`).
  - You must set custom UID for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
- Mount volumes in user's home folder.
  - The users are chrooted to their home directory, so you must mount the
    volumes in separate directories inside the user's home directory
    (/home/user/**mounted-directory**).
- A storage directory is created in the user's home directory where the user
  have full permission.
- Read user config from file.
  - Mount the file /etc/sftp_users. Each line specifies a user.

Examples
--------

### Single user and volume

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo:123:1001
```

#### Logging in

The OpenSSH server runs by default on port 22, and in this example, we are
forwarding the container's port 22 to the host's port 2222. To log in with an
OpenSSH client, run: `sftp -P 2222 foo@<host-ip>`

### Multiple users and volumes

```
docker run \
    -v /host/share:/home/foo/share \
    -v /host/documents:/home/foo/documents \
    -v /host/http:/home/bar/http \
    -p 2222:22 -d atmoz/sftp \
    foo:123:1001 \
    bar:abc:1002
```

### Storage dir

Due to security constraints the root directory when chrooting to the user's home directory must be owned by root. To give the user somewhere to store files a storage directory will be created by default. The name of the storage directory is specified in the environment variable STORAGE_DIR, default value `storage`. If set to empty no directory will be created.

### Encrypted password

Add `:e` behind password to mark it as encrypted. Use single quotes.

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

Tip: you can use makepasswd to generate encrypted passwords:  
`echo -n 123 | makepasswd --crypt-md5 --clearfrom -`

### Using SSH key (without password)

There are two methods to use ssh keys. 

This method mounts all public keys in the user's `.ssh/keys/` folder. All keys are automatically
appended to `.ssh/authorized_keys`.

```
docker run \
    -v /host/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
    -v /host/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

The second method is to add `:k` behind password to mark it as a public key instead of password. 

```
docker run \
    -v /host/share:/home \
    -p 2222:22 -d atmoz/sftp \
    'foo:ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzqrrFRdAoKRQYuUpv0jaosnv6FPqVMNy6psodAbFJvtft8x2d5V/Y22PZbJaTyBtblEmzUDSFSDFWEFWEFWEFWEFWEFWEFWEFWEFWEFSDF234234234234234234234234234234234ghAeKK6getbV8Js83JSdb6vBZ6nISTAybcmCVVmC2Bt+90eBEzD5j7KUnth9T80usI2a1RVytQNxkZXTqRBLSMzLI6gPT3AroBcOaTtNh8LzkDfaCfMM234234234234234234aPSOR5IYrQrrC2Cl4AFNL0h5FpmkEzcLFcQYcKtKhcRYo53jTsdfsdfsdf3vKbJRGRf2w== foo@laptop-foo:k:1000:1000'
```

### Specify users in file

When having many users it's more convenient to specify them in a file instead of on the command line. By mounting /etc/sftp_users into the container that file will be processed on startup and specified users will be created.

```
docker run \
    -v /host/sftp_users:/etc/sftp_users:ro \
    -v /host/share:/home \
    -p 2222:22 -d atmoz/sftp
```