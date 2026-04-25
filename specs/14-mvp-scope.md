# 14 — MVP Scope

> **Version:** 0.1-MVP | **Status:** Planning
> This file is the single source of truth for what IS and ISN'T in the MVP.
> When in doubt whether to build something: check this file first.

---

## MVP Definition

The MVP ships when a child can:
1. Open the app and play any of 3 Module A scenarios to completion.
2. Play a Module B memory game to completion.
3. Tap vocabulary cards in Module C and hear Thai TTS.

And a parent can:
4. Create an account.
5. View which scenarios the child played and for how long.
6. Toggle scenarios on/off.

---

## ❌ Out of MVP (Backlog)

### Content
- Additional Module A scenarios beyond 3
- Additional Module B memory packs
- Additional Module C vocabulary beyond 30
- English localisation
- Thai/English bilingual mode

### Child Features
- Multiple child profiles
- Child progress visible to child (stars, badges)
- In-app achievements / rewards system
- Difficulty levels per scenario
- Timed challenges

### Parent Features
- Push notifications ("น้องยังไม่ได้เล่นวันนี้")
- Detailed session replay (drag path visualisation)
- Motor skill trend graph (straightness over time)
- Goal setting per scenario
- PDF progress reports
- Family sharing (multiple parent accounts)

### Technical
- Offline mode (full offline play)
- Admin CMS for content editors (non-engineer scenario creation)
- Cloud Functions for straightness score calculation
- Analytics (Firebase Analytics events)
- A/B testing infrastructure
- Biometric auth for parent gate
- App Store / Play Store optimised listing

### Platform
- iOS tablet
- Android phone
- iOS phone

---

## Phase Roadmap

| Phase | Target | Key Additions |
|---|---|---|
| **MVP** | Pilot with 20 families | 3 scenarios, 1 memory pack, 30 vocab, parent auth + log |
| **v1.1** | Public launch (Android) | Motor skill graph, 10 scenarios, 3 memory packs |
| **v1.2** | iOS launch | iOS support, biometric parent gate |
| **v2.0** | Growth | Multiple child profiles, push notifications, admin CMS |
| **v3.0** | Monetisation | Premium scenario packs, family subscription |

---

## MVP Build Order (Suggested Sequence)

```
Week 1-2:   Firebase setup + Auth flow (parent side first)
Week 2-3:   Firestore schema + Riverpod providers
Week 3-4:   Flame game engine + drag-drop (1 scenario hardcoded)
Week 4-5:   JSON scenario template system (replace hardcoded)
Week 5:     TTS integration + haptics
Week 6:     Module B (Memory) + Module C (Sound Board)
Week 7:     Parent dashboard (log + toggle)
Week 8:     Design polish (theme, animations, Sarabun font)
Week 9:     QA + edge cases + device testing (10" Android tablet)
Week 10:    Pilot build + TestFlight/internal track release
```
