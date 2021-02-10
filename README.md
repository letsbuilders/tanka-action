# Tanka Github Action

This deploys a [Tanka](https://tanka.dev) environment to a Kubernetes cluster. 
It assumes that a valid [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file is available.

## Inputs

### `project_rootdir`

**Optional** Path to your Tanka project as documented in [Tanka docs](https://tanka.dev/directory-structure). Defaults to `.`

### `environment_basedir`

**Optional** Path to your Tanka environment as documented in [Tanka docs](https://tanka.dev/directory-structure). Defaults to `environments/default`


### `params` 

**Optional** Specify external --ext-str arguments. tag=latest env=prod becomes --ext-str tag=latest --ext-str env=prod. Use either of comma, space or semicolon as argument separator.

## Example usage

```yaml
uses: letsbuilders/tanka-action@master
with:
  project_rootdir: 'deploy'
  environment_basedir: 'environments/default'
```    

## Credit

This Action was heavily inspired by [jsonnet-render](https://github.com/marketplace/actions/jsonnet-render)
