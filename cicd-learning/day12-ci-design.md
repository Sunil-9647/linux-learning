# Day-12 CI Design (My Pipeline)

## Triggers
- pull_request to main: run quality checks before merge  
- push to main: run the same checks after merge  
- workflow_dispatch: allow manual run  

## Jobs
1) lint: validate shell scripts (quality gate)  
2) build: run build.sh and produce build log  
3) test: run test.sh and produce test log  

## Evidence (Artifacts)
- Upload all *.log files even if build/test fails (for debugging)  

---
