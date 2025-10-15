# Workspaces

## Setup

Create workspace and initialize git repository.

```bash
PROJECT="my-project"
mkdir -p $PROJECT
cd $PROJECT
git init
cat > .gitignore <<EOF
.venv
__pycache__
*.pyc
.ipynb_checkpoints
EOF
```

Create Python virtual environment and install Jupyter kernel.

```bash
# Run on host machine terminal
VERSION="3.11" # Minor version
"python${VERSION}" -m venv .venv
source .venv/bin/activate
pip install ipykernel nbconvert
```

Add kernel to JupyterHub.

```bash
# Run inside JupyterHub integrated terminal
python -m ipykernel install --user --name=$PROJECT
```

Push the repository to GitHub when ready and update the [README](../README.md#repositories) with a link to the new workspace.