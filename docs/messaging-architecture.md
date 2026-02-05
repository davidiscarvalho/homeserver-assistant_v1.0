# OpenClaw Messaging Architecture Guide

**WhatsApp/Telegram as INBOX · Slack as WORKSPACE · Brain (SQLite+Markdown) as BRAIN**

---

## 1. Introduction

OpenClaw is a personal AI operator responsible for execution, planning, prioritization, and memory management across multiple domains such as calendar, email, tasks, and knowledge.

This guide defines a **strict but scalable messaging architecture** that prevents context pollution while allowing deep collaboration with OpenClaw.

The core principles are:

- Fast capture without thinking
    
- Deep discussion where context lives
    
- Long-term memory in a single source of truth
    

---

## 2. High-Level Architecture

```
User
  ↓
WhatsApp/Telegram (INBOX)
  ↓
OpenClaw (Intent + Routing Engine)
  ↓
┌───────────────┬───────────────┬───────────────┐
│ Slack         │ Brain         │ External      │
│ (Workspace)   │ (SQLite+MD)   │ Services      │
│               │               │ (Mail, Cal)   │
└───────────────┴───────────────┴───────────────┘
  ↑
WhatsApp/Telegram (Confirmations / Notifications)
```

---

## 3. Core Philosophy

### 3.1 Separation of Responsibilities

|Layer|Responsibility|
|---|---|
|WhatsApp/Telegram|Intake and notifications|
|Slack|Thinking, discussion, execution|
|Brain (SQLite+MD)|Memory and knowledge|

Each layer has **non-overlapping duties**.

---

## 4. WhatsApp/Telegram: The OpenClaw INBOX

### 4.1 Purpose

WhatsApp/Telegram is a **single universal intake point**.

It is optimized for:

- Speed
    
- Low friction
    
- Mobile usage
    

It is **not** optimized for reasoning or planning.

---

### 4.2 Rules

- Exactly **one WhatsApp/Telegram chat**
    
- No topic separation
    
- No long discussions
    
- No historical reasoning
    

Mental model:

> “Everything here is intake, not work.”

---

### 4.3 Supported Inputs

- Commands
    
- Ideas
    
- Voice notes
    
- Forwarded content
    

Examples:

- “Add meeting tomorrow at 15h”
    
- “Summarize today’s work inbox”
    
- “Save this idea”
    
- “Remind me next month”
    

---

## 5. Command Grammar (Optional)

OpenClaw accepts both **natural language** and **lightweight prefixes**.

### 5.1 Prefix Examples

```
calendar: move meeting with Ana to Friday
mail: summarize inbox work
todo: add review contract
obsidian: save note about pricing
```

If no prefix is provided, OpenClaw infers intent.

---

## 6. Intent Resolution & Routing

### 6.1 Intent Categories

|Intent|Destination|
|---|---|
|Scheduling|Calendar|
|Email actions|Mail service|
|Tasks|Slack + Brain (SQLite)|
|Planning|Slack|
|Notes / ideas|Brain (Markdown + SQLite index)|
|Unknown|Brain inbox (`brain/inbox.md`)|

---

### 6.2 Routing Rules

1. Detect intent
    
2. Identify owning domain
    
3. Route to correct Slack channel or system
    
4. Persist memory if applicable
    
5. Confirm via WhatsApp/Telegram
    

---

## 7. Slack: The OpenClaw WORKSPACE

### 7.1 Purpose

Slack is where you **actively work with OpenClaw**.

It supports:

- Multi-step reasoning
    
- Discussion
    
- Planning
    
- Prioritization
    
- Review
    

Slack is a **first-class interaction surface**, not a backend.

---

### 7.2 Channel = Domain (Critical Rule)

Slack channels represent **bounded domains**.

> **Discussions must happen in the channel that owns the outcome.**

There is **no generic “open conversation” channel**.

---

### 7.3 Recommended Channel Structure

```
#openclaw-todo          → task planning, prioritization
#openclaw-calendar      → scheduling decisions
#openclaw-mail-work     → work email rules and triage
#openclaw-mail-personal → personal inbox handling
#openclaw-obsidian      → vault structure and knowledge
#openclaw-decisions     → cross-domain or strategic decisions
#openclaw-archive       → closed or historical threads
```

---

## 8. Discussion & Planning Rules

### 8.1 Where Discussions Belong

|Type of Discussion|Correct Place|
|---|---|
|Task prioritization|`#openclaw-todo`|
|Scheduling trade-offs|`#openclaw-calendar`|
|Email handling rules|Mail-related channel|
|Knowledge organization|`#openclaw-obsidian`|
|Cross-domain strategy|`#openclaw-decisions`|

---

### 8.2 Thread Usage

- One **thread per discussion**
    
- Channel remains clean
    
- Thread contains reasoning
    
- Final message contains summary
    

---

### 8.3 Example: Multi-Step Planning

Channel:

```
#openclaw-todo
```

Message:

```
@openclaw
Plan this week:

Tasks:
- Finish resumAI onboarding
- Improve backup strategy
- Prepare client demo

Constraints:
- 3h/day
- Demo due Friday

Propose priorities and a plan.
```

All discussion stays in this channel/thread.

---

## 9. Cross-Domain Decisions (Only Exception)

Some discussions legitimately span domains.

Examples:

- Time vs product vs infra trade-offs
    
- Strategy decisions affecting multiple systems
    

### 9.1 Dedicated Channel

```
#openclaw-decisions
```

### 9.2 Required Behavior

OpenClaw must:

1. Lead discussion here
    
2. Produce a final decision
    
3. Fan out execution to other channels
    
4. Persist decision to Brain (SQLite) and regenerate projections
    

---

## 10. Brain: The OpenClaw BRAIN

### 10.1 Purpose

The Brain (SQLite + Markdown) is the **single source of truth** for:

- Structured objects in SQLite (`state/brain.db`): decisions, tasks, events, actions, audits
- Freeform notes/specs in Markdown (`brain/`): knowledge notes, research notes, policies/specs
- Generated views in `brain/projections/` (read-only)

Slack is transient.  
WhatsApp/Telegram is ephemeral.  
The brain is permanent.

---

### 10.2 Suggested Vault Structure

See `brain/README.md` for the canonical Markdown structure.

---

### 10.3 Persistence Rules

OpenClaw persists to the Brain when:

- A decision is finalized
    
- A task is created or updated
    
- A summary is produced
    
- Knowledge is generated

Implementation rule of thumb:
- Structured outcomes → write SQLite rows (`state/brain.db`) and record audits
- Freeform outcomes → write Markdown notes under `brain/`
- Regenerate views → `make projections`
    

---

## 11. WhatsApp/Telegram Confirmations & Notifications

### 11.1 Confirmation Pattern

Every WhatsApp/Telegram intake receives:

- Short confirmation
    
- Destination reference
    

Example:

> “Captured. Discussion opened in Slack → `#openclaw-todo`.”

---

### 11.2 Notifications (Optional)

WhatsApp/Telegram may be used for:

- Upcoming meetings
    
- Urgent emails
    
- Daily summaries
    

Never for discussion.

---

## 12. Anti-Patterns (Explicitly Forbidden)

- ❌ Generic Slack channels (`#openclaw-general`)
    
- ❌ Planning in WhatsApp/Telegram
    
- ❌ Moving discussions after the fact
    
- ❌ Treating WhatsApp/Telegram as memory
    
- ❌ Mixing domains in one Slack channel
    

---

## 13. Final Rules (Non-Negotiable)

1. **WhatsApp/Telegram = Intake**
    
2. **Slack = Thinking and execution**
    
3. **Channel = Domain**
    
4. **Thread = Discussion**
    
5. **Brain (SQLite+MD) = Memory**
    
6. **Discuss where the outcome lives**
    

---

## 14. Summary

This architecture:

- Matches how humans think
    
- Scales without reorganization
    
- Keeps contexts clean
    
- Allows OpenClaw to act as a true operator, not a chat toy
    
