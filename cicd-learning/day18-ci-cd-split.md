## Day 18 — CI → CD split, DEV auto-deploy, Artifact-Driven Deployments

### Goal  
Build a real DevOps pattern:  
+ CI produces versioned artifacts  
+ CD deploys those artifacts to an environment  
+ Deployment must be repeatable and safe

---

### 1. What “CD deploys versions, not code” means  
In professional pipelines:  
+ CI builds and tests the code  
+ CI creates an artifact (zip / docker image / package)  
+ CD deploys that artifact, not the repository source

This matters because artifacts are:  
+ immutable (should not change after build)  
+ traceable (linked to commit/version)  
+ reproducible (same artifact gives same output)

---

### 2. CI responsibilities (what CI should do)  
CI should:  
+ checkout code  
+ lint  
+ build  
+ test  
+ package  
+ upload artifact

CI should NOT deploy to environments in the mature design (because CI triggers frequently and deployments need control + auditing).

---

### 3. Artifact packaging strategy used  
We ensured:  
+ `ci-artifacts/` is cleaned before packaging  
+ only one `.zip` is created per run  
+ zip name includes a version

Version approach used:  
+ `VERSION=v-${GITHUB_SHA::7}`  
Example:  
+ `app-v-652c7ba.zip`  
This gives a direct mapping between:  
+ commit → artifact → deployment

---

### 4. GitHub Actions artifacts limitation  
Important learning:  
+ Artifacts belong to a specific workflow run  
+ When CD is a separate workflow, downloading artifacts from CI run is not always straightforward with `actions/download-artifact@v4`

Solution used:  
+ Trigger CD automatically using workflow_run  
+ Download artifacts from the triggering CI run using an API-based action:  
     - `dawidd6/action-download-artifact`

---

### 5. CD responsibilities (what CD should do)  
CD should:  
+ trigger after CI success (for DEV in our case)  
+ download the CI artifact  
+ unzip artifact  
+ deploy to a target path (DEV)  
+ keep deployments versioned in folders to support rollback

Deployment structure:  
+ `$DEPLOY_PATH/$VERSION/`  

This makes rollback conceptually easy:  
+ deploy older version folder when needed

---

### 6. Common failure we faced (real world)  
**Issue: Permission denied**  
Error seen:  
+ `mkdir: cannot create directory '/app-v-xxxx': Permission denied`

Root cause:  
+ `DEPLOY_PATH` was empty or pointing to a root path (`/`), which is not writable.

Fix:  
+ Set secret `DEPLOY_PATH` to a writable directory:  
    + Example: `/home/runner/dev-deployments`

---

### 7. Final outcome  
+ CI runs successfully and uploads one artifact  
+ CD triggers automatically after CI success  
+ CD downloads artifact and deploys to DEV path successfully

---

