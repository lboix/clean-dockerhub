# clean-dockerhub

## What is it ?
A simple repo allowing you to create an image that will clean your old or not pulled manifests and reclaim storage space in your DockerHub account.

You can easily adapt this code to create your customized image that you will be able to run using a cron job.

## Rules hardcoded in the current script
- it will only clean the repos starting with *webapp-* (you can tune it using the *REPO_PREFIXES* variable)
- it can not clean more than 100 manifests in a repo in a run, as currently the */manifests* endpoint provided by the DockerHub API does not handle pagination (no "next" URL returned)
- if a manifest is tagged with word *latest* or *backup* it will be ignored (you can tune it at line 74)
- if a manifest has not been pulled since 1 month, it will be deleted (you can tune it at line 83)
- if a manifest has never been pulled, it will be deleted

## Description of environment variables used by the current script
- DOCKERHUB_USERNAME : the username of your DockerHub account
- DOCKERHUB_PASSWORD : the password of your DockerHub account
- DOCKERHUB_NAMESPACE : the namespace you want to clean in your DockerHub account (all its repos will be visited)

## How to build your first clean-dockerhub image ?
- simply git clone this repo
- read [main.sh](main.sh) and adapt it according your needs (do not hesitate to ask questions here!)
- use the [Dockerfile](Dockerfile) to build and push your clean-dockerhub image (you can use the [.gitlab-ci.yml](.gitlab-ci.yml) template if host your repo in Gitlab)

## How to use it ?
- if you want to run the *main.sh* yourself locally, make sure to replace *date* with *gdate* if you are on MacOs / Unix
- you can of course test it locally using docker like this :
```
docker run -e DOCKERHUB_USERNAME=your-username -e DOCKERHUB_PASSWORD=your-password -e DOCKERHUB_NAMESPACE=your-namespace THE_DOCKER_IMAGE_YOU_BUILT_ABOVE "./main.sh"
```
- after that you can setup it on your Linux instance using *crontab* command, or use a CronJob in your Kubernetes cluster like this :
```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: clean-dockerhub
  namespace: your-namespace
spec:
  # keep in mind: the server time is usually in GMT
  schedule: "0 10 * * 1-5"
  suspend: false
  concurrencyPolicy: Replace
  jobTemplate:
    spec:
      backoffLimit: 0
      template:
        spec:
          containers:
            - name: clean-dockerhub
              image: your-repo/clean-dockerhub:latest
              env:
                - {name: DOCKERHUB_USERNAME, valueFrom: {secretKeyRef: {name: your-secret, key: username}}}
                - {name: DOCKERHUB_PASSWORD, valueFrom: {secretKeyRef: {name: your-secret, key: password}}}
                - {name: DOCKERHUB_NAMESPACE, value: "your-dockerhub-namespace"}
          restartPolicy: Never
          imagePullSecrets: [{name: your-secret}]
```

## Improvement ideas
- offer a dry-run mode (in the meantime you can simply comment the calls to *delete_digest* function)
- move the *REPO_PREFIXES* handling in an environment variable
- move the reserved tag words *backup* and *latest* in an environment variable
- move the 1 month / 30 days value in an environment variable
- anything else you think about, just let me know!