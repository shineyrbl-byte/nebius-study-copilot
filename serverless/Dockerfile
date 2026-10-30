# Runs the morning brief and weekly planner as a Nebius Serverless Job.
# Build from the repo root:  docker build -f serverless/Dockerfile -t study-copilot-job .
FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends bash curl jq perl ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY bin/ /app/bin/
COPY serverless/run-job.sh /app/run-job.sh
ENV DEADLINES_FILE=/data/deadlines.md \
    BRIEFS_DIR=/tmp/out/briefs \
    PLANS_DIR=/tmp/out/plans \
    JOB_TASK=all
ENTRYPOINT ["bash", "/app/run-job.sh"]
