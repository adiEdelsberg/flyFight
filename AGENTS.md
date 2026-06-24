# AI Development Instructions

Before making any code changes:

1. Read GAME_CONTEXT.md
2. Follow existing architecture
3. Keep systems modular

---

# Coding Principles

## Simplicity

Prefer simple solutions.

Avoid unnecessary abstractions.

---

## Readability

Code should be understandable by a solo developer.

Avoid clever code.

Prefer explicit code.

---

## Scalability

Design systems so future ships, weapons and abilities can be added without major rewrites.

---

## Roblox Best Practices

Use:

* ModuleScripts
* Services
* Shared configs

Avoid:

* Giant scripts
* Duplicated logic
* Hardcoded values

---

# Architecture Rules

Server owns:

* Kills
* Damage
* Respawns
* Validation
* Game state

Client owns:

* Input
* Camera
* Visual effects
* Local feedback

Never trust client damage requests.

---

# Folder Structure

src/

client/

* Controllers
* UI

server/

* Services

shared/

* Configs
* Utilities
* Types

---

# Flying System Rules

FlyingShipService is the core system.

Requirements:

* Support PC
* Support Mobile
* Support Controller
* Support future ship classes
* Support future abilities

Input must be device-independent.

---

# Feature Development Process

Build features in this order:

1. Flying system
2. Input system
3. Respawn system
4. Weapons
5. Session stats
6. Ship classes
7. Abilities
8. Cosmetics

Never skip ahead.

---

# Performance Requirements

Always consider:

* Mobile performance
* Network traffic
* Memory usage

Avoid server-heavy per-frame calculations.

Prefer efficient solutions.

---

# Code Review Checklist

Before finishing any task:

* Is it modular?
* Is it scalable?
* Is it mobile friendly?
* Is it easy to understand?
* Does it follow GAME_CONTEXT.md?

If not, improve it.
