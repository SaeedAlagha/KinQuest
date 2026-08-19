# Family Pilot Playbook

The purpose of a pilot is to learn whether Sila creates repeatable shared family
moments—not merely whether people can tap through the interface.

## Recommended pilot

- **Cohort:** 5–10 volunteer families with varied ages and household sizes.
- **Duration:** 7 days.
- **Cadence:** one 10–15 minute shared Sila moment on at least 3 days.
- **Supported journeys:** one Quick Play game, one family mission, one official
  competition, one reward, and one saved memory.
- **Environment:** a dedicated pilot Firebase project and backend, never a
  developer's personal environment.

These are recommended starting parameters, not completed study results.

## Before inviting families

- Complete every item in the release checklist.
- Provide plain-language English and Arabic consent information covering what is
  collected, why, retention, deletion, support, and whether minors participate.
- Obtain the required guardian consent before collecting data from a child.
- Create a support contact and a private issue log.
- Define how a family can leave the pilot and request deletion.
- Avoid collecting sensitive free text that the pilot does not need.
- Train facilitators not to paste family content, tokens, or credentials into
  public chat or issue trackers.

## Session flow

1. Ask the family to create or join one family space.
2. Let them choose a Quick Play experience without facilitator direction.
3. Complete one mission and explain any proof step in plain language.
4. Let the family choose a reward together.
5. Save a memory only if everyone is comfortable.
6. Switch language or appearance if relevant to the household.
7. End with five short questions and an open comment.

## Metrics to record

| Signal | How to measure | Initial target |
| --- | --- | --- |
| Time to first shared activity | Start to first game/mission start | Under 3 minutes |
| Core-loop completion | Mission/game → reward or memory | At least 80% of sessions |
| Unassisted navigation | Journey completed without facilitator action | At least 80% |
| Repeat use | Family returns on 3 separate days | At least 60% of families |
| Perceived connection | 1–5 response after a shared session | Median 4 or higher |
| Safety/privacy confidence | 1–5 response after explanation | Median 4 or higher |
| Blocking defects | Crash, data leak, broken auth, unusable route | Zero unresolved |

Targets are hypotheses. Report the actual numerator, denominator, and cohort;
do not present targets as achieved outcomes.

## Five-question interview

1. What did your family enjoy most?
2. Where did anyone feel confused or left out?
3. Did the reward feel fair and motivating?
4. Did you understand what Sila saved and who could see it?
5. What would make your family use Sila again next week?

## Issue severity

- **P0 — Stop pilot:** privacy exposure, cross-family access, credential leak,
  destructive data error, or unsafe child experience.
- **P1 — Fix before next session:** crash, blocked core loop, broken login/family
  setup, or unrecoverable reward/token error.
- **P2 — Schedule promptly:** confusing flow, major layout problem, incorrect
  Arabic/RTL behavior, or repeated AI content failure with a usable fallback.
- **P3 — Improve:** copy, polish, low-frequency visual issue, or enhancement.

For every issue, record build SHA, platform, viewport/device, language, theme,
reproduction steps, expected/actual result, timestamp, and a privacy-safe image.

## Pilot closeout

- Export only the agreed aggregate metrics.
- Fulfil deletion requests and document completion privately.
- Review all P0/P1 issues before expanding the cohort.
- Convert findings into prioritized GitHub issues with an owner and acceptance
  criteria.
- Prepare a one-page evidence summary separating observations, measurements,
  participant quotes with consent, and future hypotheses.
