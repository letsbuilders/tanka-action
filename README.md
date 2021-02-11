# Tanka Github Action

This deploys a [Tanka](https://tanka.dev) environment to a Kubernetes cluster. 

It assumes that a valid [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file is available, 
meaning that you need to take care to make one available to the container in which this action is being run. See [Examples]() for suggestions on how to do that. 

## Inputs

### `project_rootdir`

**Optional** Path to your Tanka project as documented in [Tanka docs](https://tanka.dev/directory-structure). Defaults to `.`

### `environment_basedir`

**Optional** Path to your Tanka environment as documented in [Tanka docs](https://tanka.dev/directory-structure). Defaults to `environments/default`

### `params` 

**Optional** Specify external --ext-str arguments. tag=latest env=prod becomes --ext-str tag=latest --ext-str env=prod. Use either of comma, space or semicolon as argument separator.

## Example usage

### Copy the kubeconfig from your home directory

```yaml
- name: copy kubeconfig to workspace
  run: cp $HOME/.kube/config kubeconfig
  
- name: Deploy with Tanka
  uses: letsbuilders/tanka-action@v1
  with:
    project_rootdir: 'deploy'
    environment_basedir: 'environments/default'
  env:
    KUBECONFIG: /github/workspace/kubeconfig
```    

### Generate a config for AWS EKS

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v1
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}
    role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    role-skip-session-tagging: true
    role-duration-seconds: 3600

- name: Update kubeconfig
  run: aws eks --region ${{ secrets.AWS_REGION }} update-kubeconfig --name ${{ secrets.CLUSTER_NAME }} --kubeconfig ${{ github.workspace }}/kubeconfig

- name: Deploy with Tanka
  uses: letsbuilders/tanka-action@v1
  with:
    project_rootdir: 'deploy'
    environment_basedir: 'environments/default'
  env:
    KUBECONFIG: /github/workspace/kubeconfig
```

## Credit

This Action was heavily inspired by [jsonnet-render](https://github.com/marketplace/actions/jsonnet-render)
