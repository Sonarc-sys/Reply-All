# Reply All: Cybersecurity Awareness Gamification Platform

**INFO49402 Capstone Project - Sheridan College**  
Group 25 | Troy Patrick, Vladimir Gappasov, Ayinkaran Ravindran  
Capstone Advisor: Syed Tanbeer

---

## Overview

Reply All is a 2D top-down pixel art game built in Godot 4 that teaches cybersecurity awareness through active, consequence-driven gameplay. Players take on the role of an IT technician navigating a pixel art office environment where non-player characters raise real-time security incidents. Rather than sitting through a passive training video, players must read, assess, and respond to realistic cybersecurity scenarios under time pressure.

The core design philosophy is threat triage. Multiple incidents appear simultaneously and the player must decide which poses the greatest risk, respond accordingly, and manage the consequences of every decision they make. Wrong answers raise a danger bar. Ignored tickets escalate automatically. Critical wrong answers trigger a 45-second breach lockdown event that requires the player to physically clear every NPC on the map before time runs out.

---

## Features

- 36 unique cybersecurity incident scenarios across four threat levels
- Dynamic danger bar and scoring system that responds to player decisions in real time
- Patience, movement chance and escalation system per NPC role type
- Critical breach lockdown event triggered by threat level 5 wrong answers
- iPad-style tablet popup UI for incident response interactions
- Phone notification system with dynamic sorting by time remaining
- Expandable phone notifications on click that can shrink again on click
- Adaptive audio system with separate tracks for standard gameplay and lockdown events
- Intro and game over cutscenes with performance-based messaging
- Post-shift Reflection Report showing all incorrect and timed-out answers with explanations
- Options menu with volume controls and adjustable shift length

---

## Threat Levels

| Level | Category | Examples |
|-------|----------|---------|
| 1-2 | Low | Forgot password, unlocked workstation, public Wi-Fi |
| 3 | Mid | Phishing email, suspicious USB, exposed RDP port |
| 4 | High | Data leak, business email compromise, insider theft |
| 5 | Critical | Active intrusion, ransomware encrypting, live data exfiltration |

Level 5 incidents trigger the critical breach lockdown event on a wrong answer.

---

## Getting Started

### Requirements

- Godot 4.6.1 stable or Godot 4.7.1 stable
- No additional dependencies or plugins required

### Running the Project

1. Clone or download this repository
2. Open Godot 4 and select **Import Project**
3. Navigate to the repository folder and select `project.godot`
4. Press **F5** or click the Run button to launch the game

### Controls

| Input | Action |
|-------|--------|
| WASD / Arrow Keys | Move player |
| E | Interact with NPC / clear lockdown station |
| Escape | Pause / return to menu |

---

## Project Structure

```
Reply-All/
├── asset/              # Sprite sheets, backgrounds, and image assets
├── audio/              # Procedurally generated WAV files for SFX and music
├── resources/
│   ├── Issue Resources/        # 36 cybersecurity scenario .tres files
│   └── Escalation Resources/   # Escalation consequence .tres files
├── scene/              # All Godot .tscn scene files
├── script/             # All GDScript .gd files
└── project.godot       # Godot project configuration
```

---

## Team Contributions

**Troy Patrick**  
SFX generation and AudioManager autoload, iPad tablet popup UI and slide-in animation, intro and game over cutscene system, Options menu, critical breach lockdown event, 24 cybersecurity issue .tres resource files, Reflection Report scene, NPC collision debugging, sprite atlas fix, patience tuning.

**Vladimir Gappasov**  
Scoring and points system, threat level danger bar with colour-coded ProgressBar, shift timer label and update system, scoreboard scene integration, issue content contributions.

**Ayinkaran Ravindran**  
Character sprite improvements, map design and Y-sorting for visual depth, OfficeUI.gd and HUD CanvasLayer implementation, NPC urgency timing per role, escalation consequence system, walking animation configuration, phone notification system and toaster banner.

---

## Technical Notes

- All audio assets were generated procedurally using Python's `wave` and `struct` modules. No external audio licensing is required.
- The AudioManager uses a finished-signal reconnect loop for music playback because `AudioStreamWAV.loop_mode` set at runtime is unreliable in Godot 4.
- The lockdown event calls `GameManager.trigger_lockdown()` directly from the popup rather than routing through the employee node to prevent a race condition with the patience system.
- All cybersecurity scenarios are stored as `.tres` resource files using a shared `CyberIssue` class, allowing new content to be added without modifying any gameplay script.
- UIDs have been stripped from resource references to ensure the project opens correctly on any machine without UID registry conflicts.

---

## Godot Version

Developed and tested on **Godot 4.6.1 stable** and **Godot 4.7.1 stable**.

---

## License

This project was developed as an academic capstone submission at Sheridan College and is intended for educational use. All cybersecurity scenario content is original and written for awareness training purposes.
