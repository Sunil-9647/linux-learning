## Day-16: Secrets, Environment Variables & Secure Configuration (GitHub Actions)

### Goal  
Learn how to handle configuration safely in CI/CD:  
+ Keep CI artifacts clean (no secrets)  
+ Inject configuration at deploy time  
+ Use environment-scoped secrets (dev/staging/prod)  
+ Add manual approval gates for environments  

---

### Key Concepts

#### 1) Secrets vs Environment Variables  
**Secrets**  
+ Sensitive values (passwords, tokens, keys)  
+ Stored encrypted in GitHub  
+ Injected at runtime  
+ Must NOT be committed to Git  
+ Must NOT be baked into artifacts  

**Environment Variables**  
+ Usually non-sensitive configuration (log level, app mode, region)  
+ Can be stored as variables  
+ Also injected at runtime  
+ Still should not be hardcoded if environment-specific  

Rule:  
> Secrets are for sensitive data. Env vars are for configuration.  

#### 2) Why secrets must NOT be inside CI artifacts  
CI artifacts must be:  
+ reusable  
+ environment-agnostic  
+ safe to store and download  

If secrets are included in artifacts:  
+ anyone with artifact access may leak credentials  
+ all environments are compromised  
+ audits and security fail  

Correct model:  
> CI builds artifact without secrets. CD deploys artifact with secrets.  

#### 3) GitHub Environments (dev/staging/production)  
We created GitHub Environments:  
+ dev  
+ staging  
+ production  

Benefits:  
+ secrets isolation per environment  
+ manual approvals (required reviewers)  
+ stronger protection for production  

#### 4) Environment-scoped secret example (DEPLOY_PATH)  
We added the same secret key name in all environments:  
+ Secret name: `DEPLOY_PATH`  

Different values per environment:  
+ dev: `deploy-env/dev`  
+ staging: `deploy-env/staging`  
+ production: `deploy-env/prod`  

In workflow, we use:  
`${{ secrets.DEPLOY_PATH }}`

The value changes automatically depending on:  
`environment: dev/staging/production`

#### 5) Why environment secret isolation is GOOD  
We intentionally tested failure by removing the staging secret.  
Result:  
+ deploy-staging failed with:  
  `mkdir: cannot create directory '': No such file or directory`

Reason:  
+ `${{ secrets.DEPLOY_PATH }}` became empty for staging  
+ proves secrets do not automatically inherit across environments  

Lesson:  
> No secret = fail. This prevents accidental deployments to wrong targets.

#### 6) Manual approval gates  
We enabled required reviewers for environments (learning mode).  
So deploy jobs paused and waited for approval.  

This simulates real-world CD:  
+ controlled promotion  
+ accountability and audit trail  
+ prevents accidental production releases  

#### 7) Pipeline hardening: enforce single artifact  
Problem:  
+ wildcards like `*.zip` can match multiple files  
+ can cause wrong artifact deployment  

Fix:  
+ clean artifact directories before packaging  
+ ensure `.gitignore` ignores generated outputs  
+ verify exactly ONE zip exists before upload/deploy  
+ fail fast if multiple zips are present

Reason:  
> Deterministic deployments require deterministic inputs.

---

### Outcome  
+ Implemented environment-scoped secrets in GitHub Actions  
+ Used the same pipeline for dev/staging/prod with different secret values  
+ Verified secret isolation by inducing controlled failure  
+ Learned secure configuration injection at deploy time  
+ Strengthened pipeline determinism by controlling artifacts  

---
