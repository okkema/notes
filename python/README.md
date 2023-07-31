# Python

Differenct versions of Python may be needed to run certain notebooks and/or dependencies. Instead of installing Python through a package manager, e.g. `apt-get`, local copies of Python are downloaded from the official [FTP](https://www.python.org/ftp/python/) site and built on the host machine. The installed executables are invokable using the following syntax: `python<minor version>`, e.g. `python3.11`. A virtual environment should be used for dependency isolation, see the workspace [documentation](../workspaces/README.md) for more details.

## Setup

Install prerequisites.

```bash
sudo apt install wget build-essential libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y
```

Download, build, and install indicated Python version.

```bash
VERSION="3.11.4" # Patch version
wget "https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz"
tar xzf "Python-${VERSION}.tgz" 
cd "Python-${VERSION}"
./configure --enable-optimizations 
sudo make altinstall
```
