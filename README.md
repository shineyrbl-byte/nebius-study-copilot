# Study & Career Copilot

A private, always-on personal AI assistant for students. It remembers you, tracks
your deadlines and job applications, plans your week, writes you a brief every
morning on its own, and turns documents into action items, all inside a sandbox you control.

**Track:** Personal AI | **License:** MIT

Built for the Nebius x NVIDIA Global AI Hackathon.

## What it does

| Skill | What happens |
|---|---|
| **Persistent memory** | Facts you tell it are saved to `MEMORY.md` and survive new sessions. |
| **deadline-tracker** | Add, list, and complete deadlines in a plain-text file. |
| **morning-brief** | A short daily plan: overdue, due soon, this week, and one focus item. |
| **inbox-digest** | Drop a document in `inbox/`; it summarizes it, saves the digest, extracts dated action items, and asks before adding them to your tracker. |
| **study-planner** | "Plan my week": splits big deadlines (exams, projects) into small daily tasks for the next 7 days, using Nemotron 3 Ultra. Saved to `plans/`. |
| **job-tracker** | Paste a job or internship posting; it saves company, role, apply-by date, and requirements to `jobs.md`, offers to add the date to your tracker, and tracks status (saved, applied, interview, offer, rejected). |
| **Scheduled daily brief** | An OpenClaw cron job writes your brief to `briefs/YYYY-MM-DD.md` every morning at 7:00 with no chat needed (optionally sent to Telegram). |

Demo flow: drop a syllabus into the inbox -> the assistant extracts action items
-> you approve -> deadlines land in the tracker -> the morning brief uses them.

## Demo

- **Video (under 3 min):** _add YouTube link here_
- **Demo:** this assistant runs privately on your own machine, so there is no shared
  hosted URL. The video shows the full flow, and the setup steps below reproduce it.

## How it uses NVIDIA and Nebius

- **Model:** NVIDIA Nemotron 3 Super (`nvidia/nemotron-3-super-120b-a12b`)
  served on **Nebius Token Factory** through its OpenAI-compatible endpoint
  (`https://api.tokenfactory.us-central1.nebius.com/v1/`).
- **Agent runtime:** OpenClaw running inside an **NVIDIA OpenShell** sandbox,
  set up with **NVIDIA NemoClaw**.
- NemoClaw is pointed at Nebius using its "Other OpenAI-compatible endpoint"
  provider option. All model calls go to Token Factory.
- **Right-sized models** (`bin/nemotron.sh` picks the model per task):

  | Task | Model on Token Factory | Why |
  |---|---|---|
  | Chat, skills, inbox digest | Nemotron 3 Super `nvidia/nemotron-3-super-120b-a12b` | Good tool use for everyday calls |
  | Scheduled morning brief | Nemotron 3 Nano `nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B` | Simple formatting, runs daily, so fast and cheap (~14 s) |
  | Weekly study plan | Nemotron 3 Ultra `nvidia/Nemotron-3-Ultra-550b-a55b` | Multi-step planning across several deadlines |

  If Nano or Ultra fails, the helper falls back to Super.
- **Nebius Serverless Jobs:** the brief and planner also run as a batch job on Nebius
  AI Cloud from a small container. See [serverless/README.md](serverless/README.md).
- **Key stays out of the sandbox:** inside OpenShell the API key is a placeholder that
  the gateway swaps for the real key, so scripts in the sandbox never see your key.

## Privacy model

Two layers, described honestly:

- **Hard controls (enforced by the sandbox):** OpenShell limits which folders the
  agent can write to and which network hosts it can reach (Nebius Token Factory plus a few
  OpenClaw/npm hosts). Your files stay on your machine except for the model calls.
- **Soft controls (instructions to the model):** skills tell the assistant to read only the
  `inbox/` folder and to ask before changing your tracker. These guide behavior but are not
  enforced by the sandbox.

## Setup (Apple Silicon Mac)

Tested on an 8 GB MacBook with Colima. NemoClaw is alpha software; details may change.

1. Get a Nebius Token Factory API key.
2. Install Xcode command line tools, Homebrew, then Colima and Docker:
   ```bash
   xcode-select --install
   brew install colima docker
   colima start --cpu 4 --memory 5 --disk 100
   docker context use colima
   ```
3. Colima does not create `/var/run/docker.sock`, which the OpenShell gateway looks for.
   Link it:
   ```bash
   sudo ln -sf ~/.colima/default/docker.sock /var/run/docker.sock
   ```
4. Install NemoClaw and onboard:
   ```bash
   export COMPATIBLE_API_KEY="your-nebius-key"
   curl -fsSL https://www.nvidia.com/nemoclaw.sh | bash
   nemoclaw onboard
   ```
   Choose **OpenClaw**, then **Other OpenAI-compatible endpoint**, base URL
   `https://api.tokenfactory.us-central1.nebius.com/v1/`, model
   `nvidia/nemotron-3-super-120b-a12b`, sandbox name `my-assistant`.
   Skip web search and messaging channels.
5. Install the skills and helper script into the sandbox:
   ```bash
   openshell sandbox upload my-assistant ./skills /sandbox/.openclaw/workspace/skills
   openshell sandbox upload my-assistant ./bin /sandbox/.openclaw/workspace/bin
   nemoclaw my-assistant connect
   # inside the sandbox shell:
   mkdir -p /sandbox/.openclaw/workspace/inbox /sandbox/.openclaw/workspace/summaries
   chmod +x /sandbox/.openclaw/workspace/bin/*.sh
   ls -R /sandbox/.openclaw/workspace/skills   # verify the five skills are there
   ```
   (If the upload nests folders unexpectedly, move them so each `SKILL.md` sits at
   `/sandbox/.openclaw/workspace/skills/<skill-name>/SKILL.md`.)
6. Turn on the daily brief (inside the sandbox shell, once):
   ```bash
   bash /sandbox/.openclaw/workspace/bin/schedule-brief.sh
   openclaw cron list                 # shows "morning-brief-daily"
   openclaw cron run <job id>         # optional: run it now to test
   ```
   It runs at 07:00 Asia/Kolkata. Change with `BRIEF_CRON="30 6 * * *" BRIEF_TZ=Europe/London`.
   To also get it on Telegram, set up the Telegram channel in NemoClaw and add
   `TELEGRAM_CHAT_ID=<your chat id>`.
7. Chat: `nemoclaw launch my-assistant`. Use `/new` after adding or editing a skill.

## Try it

```text
Remember this: I'm a student and my project is due November 15.
Add a deadline: lab report due November 3 (study)
Give me my morning brief
Process my inbox        (after uploading examples/syllabus-notes.txt to inbox/)
Plan my week
Save this job: <paste an internship posting>
I applied to <company>
Show my saved brief
```

You can also run the helpers directly in the sandbox shell:
```bash
bash /sandbox/.openclaw/workspace/bin/daily-brief.sh    # Nano, writes briefs/<date>.md
bash /sandbox/.openclaw/workspace/bin/weekly-plan.sh    # Ultra, writes plans/week-of-<date>.md
```

Upload the sample document:
```bash
openshell sandbox upload my-assistant examples/syllabus-notes.txt /sandbox/.openclaw/workspace/inbox/
```

## Lessons learned

- Smaller models follow a **template placed first** in a skill far better than prose rules.
- Skills named like built-in ones (for example "summarize") can lose to the built-in; distinctive
  names and trigger phrases fixed this.
- Models are unreliable at date math, so `bin/brief-data.sh` and `bin/plan-data.sh` compute
  dates and the model only formats or plans with them.
- Reasoning models spend output tokens thinking first; the planner needed a bigger
  `max_tokens` budget for Ultra or the plan was cut off mid-week.
- On Colima, the OpenShell gateway needs the `/var/run/docker.sock` link.

## Feedback on Nebius and NVIDIA tools

- **Nebius Token Factory:** the OpenAI-compatible endpoint made setup easy. NemoClaw's
  "Other OpenAI-compatible endpoint" option worked with just a base URL, model name, and key.
  No GPU setup was needed on an 8 GB laptop.
- **Nemotron 3 Super:** follows skill instructions well when the reply template comes
  first. It is less reliable at date math, so a helper script computes dates.
- **Nemotron 3 Nano / Ultra:** having three sizes behind one endpoint made routing easy:
  just change the model name. Nano returns its reasoning in a separate field, so replies stay
  clean. Ultra writes good plans but needs a large token budget.
- **NemoClaw / OpenShell:** the sandbox gives real file and network limits, which suits a
  private assistant. Rough edges: on Colima the gateway expects `/var/run/docker.sock`,
  which is not created by default. Uploading folders sometimes nested them unexpectedly.
  Clearer errors for both would help.

## Limitations

- Runs locally in a sandbox; there is no hosted multi-user demo.
- The Serverless Job works from a copy of your deadlines file; it does not sync back to the sandbox.
- NemoClaw and OpenClaw are alpha and change quickly.
- Skill-level rules (such as "only read the inbox") are guidance to the model, not enforcement.

## License

MIT. See [LICENSE](LICENSE).
