# Lehigh Library Technology Skills Registry

![Expert Skills](./skills.jpeg)

A collection of personas for code reviews, architectural planning, and operational audits.

## Quick Start

The fastest way to bring these into your project is to clone this registry into either:

- your global (`~/.(claude|codex|gemini)/skills`)
- or project (`./.(claude|codex|gemini)/skills`) directory

```bash
mkdir .(claude|codex|gemini)/skills
git clone https://github.com/lehigh-university-libraries/skills.git .(claude|codex|gemini)/skills
```

Once cloned, you can activate any expert by name:
> Activate the go-expert and review the backend codebase.

## Usage Patterns

###  CLI (Native)
Cloning into `.(claude|codex|gemini)/skills/` allows the agent to automatically discover and activate these personas.
- **Trigger:** `activate_skill <name>`
- **Workflow:** The agent will follow the `Execution Workflow` and `Output Format` defined in the skill's `SKILL.md`.

### Manual
If you are using a web interface or an agent that doesn't support the `skills` folder structure:
1.  Navigate to the `SKILL.md` of the expert you need.
2.  Copy the body of the `SKILL.md` from the main heading downward.
3.  Paste it into your prompt as a "System Prompt" or "Context":
    > I want you to act as this expert: [PASTE CONTENT HERE]. Now, review the following code: ...
