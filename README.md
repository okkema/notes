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
cd python
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
mkdir -p "./projects/$PROJECT"
cd "./projects/$PROJECT"
git init
cat > .gitignore <<EOF
.venv
__pycache__
*.pyc
.ipynb_checkpoints
EOF

# Create virtual environment and install kernel. Run on host machine terminal.
"python${VERSION}" -m venv .venv
source .venv/bin/activate
pip install ipykernel

# Add kernal to JupyterHub. Run inside JupyterHub integrated terminal.
python -m ipykernel install --user --name=$PROJECT
```

## GitHub Workflows
- [issues](.github/workflows/issues.yaml) - Adds new issues to default project
- [terraform](.github/workflows/terraform.yaml) - Builds worker and runs [terraform](./terraform/) to deploy infrastructure