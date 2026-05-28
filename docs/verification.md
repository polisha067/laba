# Verification Checklist

## Prerequisites
- Kubernetes cluster with nodes labeled:
  ```bash
  kubectl label node <node-name> workload=system
  kubectl label node <node-name> workload=app
  kubectl label node <node-name> workload=app disk=fast