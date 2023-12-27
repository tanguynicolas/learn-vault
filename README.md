Pré-requis :

```plaintext
# https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files

sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512

# /etc/sysctl.conf
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
```

Démarrer le cluster :

```shell
kind create cluster --config=kind-config.yaml
```

Obtenir des informations sur le cluster Kind :

```shell
kubectl cluster-info --context kind-discovering-vault
```

Installer Cilium :

```shell
docker pull quay.io/cilium/cilium:v1.14.4
kind load --name discovering-vault docker-image quay.io/cilium/cilium:v1.14.4

source manifests/cilium/chart.sh
helm repo add ${CHART_REPO_NAME} ${CHART_REPO_URL}
helm repo update
helm upgrade --install ${CHART_RELEASE_NAME} ${CHART_PATH} \
    --namespace=${CHART_NAMESPACE} \
    --create-namespace \
    -f manifests/cilium/values.yaml
```

Obtenir des informations sur Cilium :

```shell
cilium status --wait
cilium connectivity test
```

Obtenir des informations sur Hubble :

```shell
cilium hubble port-forward&
hubble status
hubble observe
cilium hubble ui
```

Génération de la PKI et des certificats pour Vault.

```plaintext
mkdir -p /opt/ca /opt/vault

cfssl gencert \
    -initca \
    /opt/csr.json | cfssljson -bare /opt/ca/ca

cfssl gencert \
    -ca=/opt/ca/ca.pem \
    -ca-key=/opt/ca/ca-key.pem \
    -config=/opt/ca-config.json \
    -hostname="vault,vault.vault.svc.cluster.local,vault.vault.svc,localhost,127.0.0.1" \
    -profile=default \
    /opt/csr.json | cfssljson -bare /opt/vault/vault

kubectl -n vault create secret tls tls-ca \
    --cert pki/ca/ca.pem \
    --key pki/ca/ca-key.pem
kubectl -n vault create secret tls tls-vault \
    --cert pki/vault/vault.pem \
    --key pki/vault/vault-key.pem
```

Installer Vault :

```shell
source manifests/vault/chart.sh
helm repo add ${CHART_REPO_NAME} ${CHART_REPO_URL}
helm repo update
helm upgrade --install ${CHART_RELEASE_NAME} ${CHART_PATH} \
    --namespace=${CHART_NAMESPACE} \
    --create-namespace \
    -f manifests/vault/values.yaml

kubectl -n vault exec -it vault-0 -- vault operator init
  # Unseal Key 1: M11/Gpa4W5xZR8JFxYpzAG1yfVODr6eLKq/ul7oRWXOq
  # Unseal Key 2: LXFgas2Mx02/J4DCcwNCdz+6XDOWt9F7uUVn8UUHxC4R
  # Unseal Key 3: l6cPJ6K10OCcZfbgLjfE3qNswBbIJasyOpZpUv5gvypi
  # Unseal Key 4: LNFEXpcg7t+oUZE5nb7AL61deTxX7tbed9qptZyj4a8+
  # Unseal Key 5: KpSpMiTT7I3/b8/nEIMAd214R5paapCCDNJ5c4X9Feen
  # 
  # Initial Root Token: hvs.0cNexRiv8pu3Z9hQRPWzBj0M
  # 
  # Vault initialized with 5 key shares and a key threshold of 3. Please securely
  # distribute the key shares printed above. When the Vault is re-sealed,
  # restarted, or stopped, you must supply at least 3 of these keys to unseal it
  # before it can start servicing requests.
  # 
  # Vault does not store the generated root key. Without at least 3 keys to
  # reconstruct the root key, Vault will remain permanently sealed!
  # 
  # It is possible to generate new unseal keys, provided you have a quorum of
  # existing unseal keys shares. See "vault operator rekey" for more information.

kubectl -n vault exec -it vault-0 -- vault operator unseal

hubectl -n vault port-forward service/vault 8200:8200
```
