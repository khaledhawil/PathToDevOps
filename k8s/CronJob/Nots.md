# CronJob
A CronJob in Kubernetes is a resource that allows you to run jobs on a scheduled basis, similar to the cron utility in Unix/Linux. It is useful for tasks that need to be executed periodically, such as backups, report generation, or any recurring batch jobs.

## Key Points about CronJobs:
- Scheduling: CronJobs use a cron-like syntax to define the schedule for running jobs (e.g., every minute, daily, weekly).

- Job Management: Each scheduled execution creates a Job, which then runs a pod. Kubernetes manages these jobs, including retries and completions.

- History Limits: You can define how many completed and failed jobs to retain, helping to manage resources and keep your cluster clean.
## How to Create a CronJob:
Here's a simple example of how to create a CronJob using YAML:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: my-cronjob
  namespace: default
spec:
  schedule: "*/1 * * * *"  # This runs the job every minute
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: my-container
            image: alpine
            command: ["echo", "Hello, Kubernetes CronJob!"]
          restartPolicy: OnFailure  # Restart the job on failure
```

### View Jobs Created by the CronJob: To see the jobs created by the CronJob, you can run:
```bash
kubectl get jobs --watch
```
### View Pods: To see the pods created by the jobs, you can run:
```bash
kubectl get pods -l job-name=my-cronjob
```
