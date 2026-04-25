# 01 — Product Overview

> **Version:** 0.1-MVP | **Status:** Planning

---

## Vision Statement

**Daily Life (ชีวิตประจำวัน)** is a neuro-inclusive sandbox app for Thai children (ages 3–10) to practice real-world social and motor skills through gentle, gamified scenarios — with zero failure states, zero frustration, and maximum celebration.

---

## Design Philosophy

| Principle | What it means in practice |
|---|---|
| **Sandbox Freedom** | No Game Over. No timer. Items always return softly to start. Child cannot break anything. |
| **Celebration-first** | Every correct action gets a TTS cheer, golden sparkle, and haptic buzz. Wrong placements are silently ignored. |
| **Minimalist Cognitive Load** | One task per screen. One instruction at a time. No pop-ups during play. |
| **Thai-Centric** | Scenes are 7-Elevens, Thai markets, Thai homes. Not generic western environments. |
| **Parent-invisible** | The child's experience has zero UI chrome for parents — no logout, no settings, no scores. |
| **Infinitely scalable** | Every scenario is a JSON file. No engineer needed to ship new content. |

---

## Target Users

### Primary — The Child

- Age: 3–10 (fine motor range varies widely)
- Neurodiversity: designed for but not limited to autism, ADHD, DCD, Down syndrome
- Thai-speaking, may not be literate
- Short sessions: 3–15 minutes
- Uses tablet (primary) or phone (secondary)

### Secondary — The Parent / Caregiver

- Thai-speaking parent, teacher, or therapist
- Wants to set focus areas and review progress
- Uses phone or tablet, typically after the child's session
- Not necessarily tech-savvy; must be zero-configuration

---

## MVP Scope Summary

> Full detail in `14-mvp-scope.md`. This is the 30-second version.

**In MVP:**
- Module A: 3 scenarios (711 milk, trash sorting, food prep)
- Module B: Memory game (1 pack of 8 Thai cultural icon pairs)
- Module C: Sound Board (30 vocabulary items)
- Parent dashboard: auth + activity log + scenario toggle
- Firebase backend (Firestore + Auth)
- Neural TTS for all instructions + celebrations
- Yellow/Blue warm theme, fully implemented

**Out of MVP:**
- In-app purchases
- Multiple child profiles
- Push notifications
- Offline mode
- Admin CMS for content editors
- English localisation

---

## Platform Targets

| Platform | Priority | Notes |
|---|---|---|
| Android tablet (10"+) | P0 — MVP | Primary device for Thai families |
| iOS tablet (iPad) | P1 — post-MVP | Required for App Store |
| Android phone | P1 — post-MVP | Smaller hitboxes need redesign pass |
| iOS phone | P2 | Same as Android phone |
| Web | Out of scope | |

---

## Success Metrics (MVP)

- Child completes ≥1 scenario without caregiver intervention
- Parent can set up an account and enable/disable a scenario in under 3 minutes
- 0 crash reports in first 30 days of pilot
- ≥80% of drag-drop interactions register correctly on a 10" tablet

---

## Glossary

| Term | Definition |
|---|---|
| **Scenario** | One self-contained play session (background + objects + instruction + drop zone) |
| **Interactable** | A draggable object in the scene |
| **Target** | The interactable that must be placed in the drop zone to succeed |
| **Distractor** | A non-target interactable; ignored when dropped in the zone |
| **Drop Zone / Basket** | The collision box that triggers success |
| **TTS** | Text-to-Speech; all spoken audio is generated, never recorded |
| **Module** | A top-level game mode (A = Daily Life, B = Memory, C = Sound Board) |
| **Template** | The JSON schema that defines a scenario; data-only, no code |
