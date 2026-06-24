# Flying Ship Arena

## Overview

Flying Ship Arena is a fast-paced Roblox PvP game where players control flying ships in a shared arena.

The game is designed around extremely simple and addictive gameplay:

* Spawn instantly
* Fight immediately
* One hit = one kill
* Quick respawn
* No waiting for rounds
* Constant action

The game should feel easy to learn but difficult to master.

---

# Core Gameplay Loop

1. Player spawns in a flying ship.
2. Player flies around the arena.
3. Player attacks other players.
4. One successful hit destroys the enemy ship.
5. Attacker receives a kill.
6. Destroyed player plays a short destruction animation.
7. Destroyed player respawns at a random spawn point.
8. Gameplay continues indefinitely.

---

# Design Philosophy

## Simplicity First

Every feature should be evaluated against:

"Does this make the game more fun within the first 30 seconds?"

Avoid unnecessary complexity.

---

## Fast Action

Players should never wait long.

Target:

* Respawn time: 1-2 seconds
* Fast movement
* Fast combat
* Fast rewards

---

## Skill-Based Gameplay

Players improve through:

* Aim
* Movement
* Positioning
* Dodging
* Ship mastery

Not through grinding.

---

# Technical Vision

The flying system is the foundation of the entire game.

Everything should be built around the assumption that:

* New ships will be added
* New abilities will be added
* New weapons will be added
* New maps will be added

The architecture must support future expansion without major rewrites.

---

# Main Systems

## FlyingShipService

Responsible for:

* Spawning ships
* Destroying ships
* Respawning ships
* Ship ownership
* Ship configuration
* Future ship classes

This is the most important system in the game.

---

## Input System

Must support:

* PC
* Mobile
* Controller

All devices should be normalized into shared actions.

Example:

Move
Turn
Ascend
Descend
Boost
Fire

Game systems should never care which device generated input.

---

## WeaponService

Responsible for:

* Firing weapons
* Hit detection
* Damage validation
* Kill validation

Server authoritative.

---

## StatsService

Tracks:

* Session kills
* Session deaths
* Kill streaks
* Best streak

Stats reset when leaving server.

---

## RespawnService

Responsible for:

* Random spawn selection
* Respawning ships
* Spawn protection (future)

---

# Combat Rules

Current MVP:

* One hit = one kill
* Health = 1

Future:

* Multiple ship classes
* Different health values
* Shields
* Abilities

---

# Future Ships

Example:

BasicShip
HeavyShip
ScoutShip
SniperShip
SupportShip

Every ship should be configurable through data, not hardcoded logic.

---

# Performance Goals

Target:

* Smooth gameplay on mobile
* Smooth gameplay on low-end devices
* Support large player counts

Avoid:

* Expensive loops
* Excessive raycasts
* Per-frame server calculations

Optimize early.

---

# Success Criteria For MVP

A player can:

* Join server
* Spawn as a flying ship
* Fly smoothly
* Shoot
* Destroy another player
* Gain kills
* Respawn instantly

If these work, the MVP is successful.
