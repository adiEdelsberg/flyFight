# Development Process

Work in very small milestones. this project connected to roblox studio project with rojo.

After every implementation:

1. User will run roblox in studio to confirm.
2. Explain what files were changed.
3. Explain what success looks like.
4. Stop and wait for user confirmation before continuing.

# Flying Ship Arena

A fast-paced Roblox PvP game where players control flying ships and battle continuously in a shared arena.

---

# Game Overview

Players spawn as flying ships and immediately enter combat.

Core gameplay:

* Fly around the arena
* Fight other players
* One hit = one kill
* Destroyed ships respawn quickly
* Session kills and deaths are tracked
* No rounds
* No waiting
* Constant action

The game is designed to be easy to learn and difficult to master.

---

# Starter Ship Asset

The first playable ship is FrogShip.

Roblox Studio location:

ReplicatedStorage/Assets/Ships/FrogShip

For MVP, every player should spawn with FrogShip.

FlyingShipService should clone this model when spawning a player ship.

Future ships should also be placed under:

ReplicatedStorage/Assets/Ships/

---

# Important Project Files

Before making any code changes, read these files:

1. AGENTS.md
2. GAME_CONTEXT.md
3. ROADMAP.md

These files define:

* Project vision
* Technical architecture
* Development priorities
* Coding standards
* Current milestone

---

# Current Milestone

Phase 1 - Core Flight Prototype

Goal:

Create a reusable FlyingShipService that supports:

* PC
* Mobile
* Controller

The flying system is the foundation of the entire game.

Do not begin advanced gameplay systems until flight feels great.

---

# Technical Goals

Architecture priorities:

* Modular Luau code
* Scalable systems
* Server-authoritative gameplay
* Mobile-friendly performance
* Easy addition of future ships
* Easy addition of future abilities
* Easy addition of future weapons

---

# Planned Core Systems

## FlyingShipService

Responsible for:

* Ship spawning
* Ship ownership
* Ship destruction
* Respawning
* Ship configuration

---

## Input System

Responsible for:

* Keyboard input
* Mobile input
* Controller input

All devices must map to the same gameplay actions.

---

## WeaponService

Responsible for:

* Shooting
* Hit validation
* Damage validation
* Kill validation

---

## StatsService

Tracks:

* Kills
* Deaths
* Streaks

Session only.

---

## RespawnService

Responsible for:

* Spawn selection
* Respawn flow

---

# Project Structure

```text
FlyingShipArena/
│
├── README.md
├── AGENTS.md
├── GAME_CONTEXT.md
├── ROADMAP.md
│
├── src/
│   ├── client/
│   ├── server/
│   └── shared/
│
└── assets/
```

# Development Rules

* Keep systems modular.
* Avoid premature optimization.
* Avoid giant scripts.
* Avoid duplicated logic.
* Follow AGENTS.md.
* Follow GAME_CONTEXT.md.
* Follow ROADMAP.md.

---

# Success Criteria

MVP is complete when:

* Players spawn as flying ships
* Players can fly smoothly
* Players can shoot
* One hit destroys a ship
* Kills are tracked
* Players respawn quickly

After MVP, focus on content expansion and progression systems.

// ProximityPrompt 