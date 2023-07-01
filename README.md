# notes
JupyterHub configurations and workspaces

## Workspaces
- [finance](https://github.com/cptchloroplast/finance)

## Setup

### Install New Python Versions
Python versions can be found on the official [FTP](https://www.python.org/ftp/python/) site.
```bash
# Install prerequisites
sudo apt install wget build-essential libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y

# Download, build, and install indicated Python version
VERSION="3.11.4"
wget "https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz"
tar xzf "Python-${VERSION}.tgz" 
cd "Python-${VERSION}"
./configure --enable-optimizations 
sudo make altinstall
```

### Create Workspace and Virtual Environment
Run these commands from within the JupyterHub integrated terminal.
```bash
# Create workspace and git repository
PROJECT="project_name"
VERSION="3.11"
mkdir $PROJECT
cd $PROJECT
git init
cat > .gitignore <<EOF
.venv
__pycache__
*.pyc
EOF

# Create virtual environment and install kernel
"python${VERSION}" -m venv .venv
source .venv/bin/activate
pip install ipykernel
python -m ipykernel install --user --name=$PROJECT
```
