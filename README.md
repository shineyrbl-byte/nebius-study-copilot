# Study & Career Copilot

A private, always-on personal AI assistant for students. It remembers you, tracks
your deadlines, plans your day, and turns documents into action items, all inside
a sandbox you control.

**Track:** Personal AI | **License:** MIT

Built for the Nebius x NVIDIA Global AI Hackathon.

## What it does

| Skill | What happens |
|---|---|
| **Persistent memory** | Facts you tell it are saved to `MEMORY.md` and survive new sessions. |
| **deadline-tracker** | Add, list, and complete deadlines in a plain-text file. |
| **morning-brief** | A short daily plan: overdue, due soon, this week, and one focus item. |
| **inbox-digest** | Drop a document in `inbox/`; it summarizes it, saves the digest, extracts dated action items, and asks before adding them to your tracker. |

Demo flow: drop a syllabus into the inbox -> the assistant extracts action items
-> you approve -> deadlines land in the tracker -> the morning brief uses them.

## How it uses NVIDIA and Nebius

- **Model:** NVIDIA Nemotron 3 Super (`nvidia/nemotron-3-super-120b-a12b`)
  served on **Nebius Token Factory** through its OpenAI-compatible endpoint
  (`https://api.tokenfactory.us-central1.nebius.com/v1/`).
- **Agent runtime:** OpenClaw running inside an **NVIDIA OpenShell** sandbox,
  set up with **NVIDIA NemoClaw**.
- NemoClaw is pointed at Nebius using its "Other OpenAI-compatible endpoint"
  provider option. All model calls go to Token Factory.

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
   ls -R /sandbox/.openclaw/workspace/skills   # verify the three skills are there
   ```
   (If the upload nests folders unexpectedly, move them so each `SKILL.md` sits at
   `/sandbox/.openclaw/workspace/skills/<skill-name>/SKILL.md`.)
6. Chat: `nemoclaw launch my-assistant`. Use `/new` after adding or editing a skill.

## Try it

```text
Remember this: I'm a student and my project is due November 15.
Add a deadline: lab report due November 3 (study)
Give me my morning brief
Process my inbox        (after uploading examples/syllabus-notes.txt to inbox/)
```

Upload the sample document:
```bash
openshell sandbox upload my-assistant examples/syllabus-notes.txt /sandbox/.openclaw/workspace/inbox/
```

## Lessons learned

- Smaller models follow a **template placed first** in a skill far better than prose rules.
- Skills named like built-in ones (for example "summarize") can lose to the built-in; distinctive
  names and trigger phrases fixed this.
- Models are unreliable at date math, so `bin/brief-data.sh` computes dates and the model only
  formats the result.
- On Colima, the OpenShell gateway needs the `/var/run/docker.sock` link.

## Limitations

- Runs locally in a sandbox; there is no hosted multi-user demo.
- NemoClaw and OpenClaw are alpha and change quickly.
- Skill-level rules (such as "only read the inbox") are guidance to the model, not enforcement.

## License

MIT. See [LICENSE](LICENSE).
