# notes

JupyterHub workspaces, pipelines, and hosting

## Workspaces

Workspaces are a collection of notebooks and other resources that share common dependencies. See the [documentation](./workspaces/README.md) for more details on creating new workspaces.

### Repositories

- [finance](https://github.com/cptchloroplast/finance)

## Pipelines

Pipelines are run using GitHub Actions. 

### Workflows

- [issues](.github/workflows/issues.yaml) - Adds new issues to default project
- [push](.github/workflows/push.yaml) - Builds worker with [npm](./package.json) and runs [terraform](./terraform/) to deploy infrastructure

## Hosting

Rendered workspace notebooks are hosted using Cloudflare Workers, R2, and Zero Trust. Workspaces are responsible for rendering notebooks to HTML and uploading them to the correct location within the bucket. 

### Subdomains

- `public` - Publicly accessible notebooks
- `private` - Private notebooks accessible through Zero Trust