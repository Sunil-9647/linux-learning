## Day-15: Environment Promotion Pipeline (dev → staging → prod)

### Goal  
Implement a real-world promotion model where:  
+ CI builds **once**  
+ CD deploys the **same artifact** across multiple environments  
+ Promotion happens sequentially: **dev → staging → prod**  
+ Production deploy requires **manual approval**  

This is a key DevOps principle: **Build once, deploy many times.**

---

### Key Concepts

#### 1) What is Environment promotion?  
Environment promotion means we take the **same build artifact** (output from CI) and deploy it to different environments without rebuilding.

+ **dev**: fast feedback, early validation  
+ **staging**: production-like validation  
+ **prod**: real users, high risk, must be controlled  

Promotion ensures:  
+ What was tested in staging is exactly what goes to prod  
+ Rollback becomes realistic (redeploy an older artifact)  
+ Audit and traceability are possible (which commit went to prod?)  

#### 2) Golden Rule: Build once  
CI is responsible for:  
+ linting  
+ building  
+ testing  
+ producing a **single reusable artifact**

CD is responsible for:  
+ downloading that artifact  
+ deploying the same artifact to environments  
+ applying environment-specific config at deploy time (not rebuilding)  

#### 3) Why production requires manual approval  
Even if staging passed:  
+ production changes real systems and real users  
+ organizations want human review for safety  
+ approval creates an audit trail: “who approved, when”  

In GitHub Actions, this is done using:  
+ `environment: production`  
+ and environment protection rules (reviewers)  

---

### Pipeline Structure

#### CI Section (Build and Validate)  
Jobs:  
1. `lint`  → code quality checks  
2. `build` → creates build output and packages artifact  
3. `test`  → validates the build result  

Output:  
- A single ZIP build artifact (versioned using commit SHA)  

#### CD Section (Promotion)
Jobs:  
1. `deploy-dev`  
   - consumes the build artifact  
   - deploys to a simulated dev folder  
2. `deploy-staging`  
   - depends on `deploy-dev`  
   - consumes the **same artifact**  
   - deploys to staging folder  
3. `deploy-prod`  
   - depends on `deploy-staging`  
   - **manual approval gate**  
   - consumes the **same artifact**  
   - deploys to prod folder  

Promotion dependencies ensure that if dev fails, staging/prod do not run.

---

### Why we removed `deploy-sim` (Day-14 Job)  
`deploy-sim` was a learning scaffold to prove:  
+ jobs can consume artifacts  

Day-15 created the real CD flow (dev → staging → prod), so keeping `deploy-sim` would:  
+ duplicate deployment logic  
+ add confusion and noise  
+ violate clean pipeline practices  

---

### Common Mistakes and Fixes

#### Mistake 1: Rebuilding in CD  
Wrong:  
+ running build scripts again in deploy jobs

Correct:  
+ deploy jobs should only download artifact and deploy it

#### Mistake 2: Wildcards matching extra ZIP files  
Problem:  
+ `unzip artifact/*.zip` can match multiple zips if workspace is dirty

Fix:  
+ ensure only intended artifact exists or select the single zip file deterministically

#### Mistake 3: Tracking build outputs in Git  
Build outputs like:  
+ `dist/`  
+ `ci-artifacts/`  
+ `*.zip`  

must not be committed.  
Use `.gitignore` to enforce repo hygiene.

---

### Outcome (What was achieved)  
+ Implemented a promotion-based CD pipeline  
+ Verified sequential deployment:  
  - deploy-dev ✅  
  - deploy-staging ✅  
  - deploy-prod ✅ (after manual approval)  
+ Production job used GitHub environment protection rules  
+ Achieved “build once, deploy many times” model  

---

### Summary  
Day-15 establishes real-world CD discipline:  
+ CI produces a trusted artifact once  
+ CD promotes the same artifact through environments  
+ production deploy is controlled by approvals

---

