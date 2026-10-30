# Run the brief and planner as a Nebius Serverless Job

The same scripts that run in the sandbox also run as a batch job on Nebius AI Cloud.
The job reads a deadlines file, calls Nemotron on Token Factory (Nano for the brief,
Ultra for the plan), and prints the results to the job logs.

Privacy: only the deadlines file you inject is sent to the job. Your memory, inbox,
and summaries stay in your local sandbox.

## 1. Install and log in to the Nebius CLI
```bash
curl -sSL https://artifacts.nebius.cloud/cli/install.sh | bash
exec -l $SHELL
nebius profile create        # opens a browser to log in, pick your project
```

## 2. Test locally (optional)
```bash
docker build -f serverless/Dockerfile -t study-copilot-job .
docker run --rm -e NEBIUS_API_KEY="your-token-factory-key" \
  -v "$PWD/examples/deadlines.example.md:/data/deadlines.md:ro" study-copilot-job
```

## 3. Push the image to Nebius Container Registry
Nebius CPU machines are x86, so build for `linux/amd64`.
```bash
export REGION_ID=us-central1          # your project's region
export REGISTRY_PATH=$(nebius registry create --name study-copilot \
  --format json | jq -r ".metadata.id" | cut -d- -f 2)
nebius registry configure-helper
IMAGE=cr.$REGION_ID.nebius.cloud/$REGISTRY_PATH/study-copilot-job:latest
docker buildx build --platform linux/amd64 -f serverless/Dockerfile -t $IMAGE --push .
```

## 4. Store your Token Factory key as a secret
Create a secret in the Nebius console (MysteryBox / SecretStash) with a payload key
named `NEBIUS_API_KEY`, then note its name or ID.

## 5. Run the job
```bash
nebius ai job create \
  --name study-copilot-brief \
  --image $IMAGE \
  --env-secret NEBIUS_API_KEY=<your-secret-name-or-id> \
  --env JOB_TASK=all \
  --inject-file "examples/deadlines.example.md:/data/deadlines.md" \
  --platform cpu-d3 --preset 2vcpu-8gb \
  --disk-size 20Gi --timeout 1h
```
Use your own deadlines file instead of the example. To get it out of the sandbox:
`openshell sandbox download my-assistant /sandbox/.openclaw/workspace/deadlines.md ./my-deadlines.md`

## 6. Read the result
```bash
JOB_ID=$(nebius ai job get-by-name --name study-copilot-brief --format jsonpath='{.metadata.id}')
nebius ai job get $JOB_ID     # status
nebius ai job logs $JOB_ID    # the brief and week plan
```
The job finishes in under a minute; it is billed per second while running.

Flag names come from the Nebius docs (docs.nebius.com/serverless/jobs/manage). If a
flag is rejected, check `nebius ai job create --help`.
