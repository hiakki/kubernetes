Ref - https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar

vault official git repo - https://github.com/hashicorp/vault-guides.git

1. Add hashicorp repo in helm -
helm repo add hashicorp https://helm.releases.hashicorp.com

2. Update helm repo -
helm repo update

3. Install vault in K8s -
helm install vault hashicorp/vault --set "server.dev.enabled=true" --create-namespace --namespace vault

4. Get into shell of vault-0 -
kubectl exec -it vault-0 -- /bin/sh

5. Inside shell of vault-0, enter following commands -

a. Enable kv-v1 and kv-v2 secrets at the path kv_v1 and kv_v2 respectively.
vault secrets enable -path=kv_v1 -version=1 kv
vault secrets enable -path=kv_v2 -version=2 kv

b. Create a secret at path kv_v1/database/config and kv_v2/database/config with a username and password.
vault kv put kv_v1/database/config username="kv-v1-user" password="kv-v1-password"

vault kv put kv_v2/database/config username="kv-v2-user" password="kv-v2-password"

c. Verify that the secret is defined at the path kv_v1/database/config and kv_v2/database/config.
vault kv get kv_v1/database/config

vault kv get kv_v2/database/config

d. Enable the Kubernetes authentication method.
vault auth enable kubernetes

e. Configure the Kubernetes authentication method to use the location of the Kubernetes API, the service account token, its certificate, and the name of Kubernetes' service account issuer (required with Kubernetes 1.21+). (Note: Make sure to change namespace in issuer)

vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.vault.svc.cluster.local"

f. Write out the policy named vault-backend that enables the read capability for secrets at path kv_v1 and kv_v2.

vault policy write vault-backend - <<EOF
path "kv_v1/*" {
    capabilities = ["read"]
}
path "kv_v2/data/*" {
    capabilities = ["read"]
}
EOF

g. Create a Kubernetes authentication role named vault-backend. (Note: Make sure to change namespace)
vault write auth/kubernetes/role/vault-backend \
    bound_service_account_names=vault-backend \
    bound_service_account_namespaces=vault \
    policies=vault-backend \
    ttl=24h

=========================================================

Now it's time to take help from some 3rd parties to fetch secrets from vault and inject it to our pods (updated secrets will update in pods after rollout restart)

A. Using external-secrets (not kubernetes-external-secrets)
(Ref - https://external-secrets.io/v0.5.1/guides-getting-started/
https://external-secrets.io/v0.5.1/provider-hashicorp-vault/)

1. helm steps -
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets \
   external-secrets/external-secrets -n vault

2. We will use "Kubernetes Authentication" for connecting with vault -

external-secrets-k8s-auth.yaml ->
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault.vault.svc:8200"
      # This is the secret path parent dir name
      path: "kv_v2"
      version: "v2"
      auth:
        # Authenticate against Vault using a Kubernetes ServiceAccount
        # token stored in a Secret.
        # https://www.vaultproject.io/docs/auth/kubernetes
        kubernetes:
          # Path where the Kubernetes authentication backend is mounted in Vault
          mountPath: "kubernetes"
          # A required field containing the Vault Role to assume.
          role: "vault-backend"
          # Optional service account field containing the name
          # of a kubernetes ServiceAccount
          serviceAccountRef:
            name: "vault-backend"
          # Optional secret field containing a Kubernetes ServiceAccount JWT
          #  used for authenticating with Vault
          # secretRef:
          #   name: "my-secret"
          #   key: "vault"

3. Deploy the above resource and verify -
k apply -f external-secrets-k8s-auth.yaml
kg secretstore vault-backend

Expected OP - 
NAME            AGE   STATUS
vault-backend   5s   Valid

4. Create a new manifest for fetching secrets from the path given in above created SecretStore -

external-secrets-fetch.yaml ->
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: test-deployment-external-secret
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: test-deployment-secret
  data:
  - secretKey: username
    remoteRef:
      key: database/config
      property: username
  - secretKey: password
    remoteRef:
      key: database/config
      property: password

5. Deploy the above resource and verify -
k apply -f external-secrets-fetch.yaml
kg externalsecret.external-secrets.io/vault-example

Expected OP - 
NAME                              STORE           REFRESH INTERVAL   STATUS
test-deployment-external-secret   vault-backend   15s                SecretSynced

6. Check for the secrets now as well -
kg secret test-deployment-secret -o yaml | yq '.data'

Expected OP -
password: NDMyMWt2LXYyLXBhc3N3b3Jk
username: ODc2NWt2LXYyLXVzZXI=

7. Now use this secret in your deployment as usual.

===============================================================================


B. Using vault-secrets-operator - (Ref - https://github.com/ricoberger/vault-secrets-operator) 

1. Now deploy vault-secrets-operator via helm -
helm repo add ricoberger https://ricoberger.github.io/helm-charts
helm repo update
helm install vault-secrets-operator ricoberger/vault-secrets-operator \
    --set "vault.authMethod=kubernetes" \
    --set "vault.address=http://vault.vault.svc:8200"
    --set "vault.kubernetesRole=vault-backend"

2. Create a VaultSecret - 
a. kv-v1-secret.yaml -

apiVersion: ricoberger.de/v1alpha1
kind: VaultSecret
metadata:
  name: kv-v1-db-secrets
spec:
  keys:
    - username
    - password
  path: kv_v1/database/config
  type: Opaque

b. kv-v2-secret.yaml -

apiVersion: ricoberger.de/v1alpha1
kind: VaultSecret
metadata:
  name: kv-v2-db-secrets
spec:
  path: kv_v2/database/config
  type: Opaque

3. Create VaultSecrets -

k apply -f kv-v1-secret.yaml
k apply -f kv-v2-secret.yaml

4. Fetch VaultSecret and Secret -
kg vaultsecret,secret
kg secret kv-v1-db-secrets -o yaml | yq '.data'
kg secret kv-v2-db-secrets -o yaml | yq '.data'

O/P -
    password: a3YtdjItcGFzc3dvcmQ=
    username: a3YtdjItdXNlcg==

5. Now use these keys as usual in deployment files.


=========================================================


Below is the way to inject Vault Secrets in Pods as ENV VARS without any 3rd parties -
a. Add following lines in deployment resource, to get vault secrets as ENV VARS -
(NOTE: If it is an Alpine container, then please install bash in it before running them with vault - apk add bash bash-doc bash-completion)

      containers:
        - name: web
          image: ubuntu
          args:
            ['sh', '-c', 'echo "source /vault/secrets/config" >> ~/.bashrc; while true; do sleep 5; done']





vault-secrets-operator - s.bVxlrYQPQJ8irFwYpMU7b5AI