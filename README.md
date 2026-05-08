# ProcBell

A small World of Warcraft addon that plays a sound when you cast specific spells or gain specific auras. Useful for proc cues, cooldown alerts, ability reminders, etc.

## Features

- Play any sound when you successfully cast a spell (e.g. Ray of Frost — spell ID `205021`)
- Play any sound when an aura newly appears on you (e.g. Vengeance Metamorphosis — spell ID `187827`)
- Pick from a curated list of WoW built-in SoundKits or your own `.ogg` files
- Add custom sounds at runtime through the UI — bare filenames like `meta.ogg` are auto-resolved to the addon folder; full paths and numeric FileDataIDs also work
- Settings persist across sessions per character (saved variables)

## Installation

### WowUp-CF (recommended)

1. Open WowUp-CF
2. **Get Addons** → menu (⋮) → **Install from URL**
3. Paste this repo's GitHub URL
4. WowUp-CF reads the latest GitHub release (via `release.json`) and updates automatically when new versions are tagged

### Manual

1. Download the latest `procbell-vX.Y.Z.zip` from [Releases](../../releases)
2. Extract into `World of Warcraft\_retail_\Interface\AddOns\`
3. `/reload` in-game (or restart the client)

## Usage

- `/procbell` (or `/pb`) — open the configuration window
- **Spell Casts** tab — bind a sound to a spell ID; sound plays on a successful cast
- **Auras** tab — bind a sound to an aura's spell ID; sound plays when the aura newly appears on you
- **Custom Sounds...** — register your own `.ogg` files (see below)

### Adding custom sounds

The addon folder gets replaced on every update, so don't drop user files into `Interface\AddOns\procbell\` — they'll vanish next time WowUp updates the addon.

Instead, create a sibling folder once:

```
World of Warcraft\_retail_\Interface\AddOns\ProcBell_UserSounds\
```

Drop your `.ogg` files in there. The folder doesn't need a `.toc` file — WoW's `PlaySoundFile` reads any file under `Interface\AddOns` regardless of whether the folder is a registered addon. WowUp won't touch a folder it didn't install, so the files persist across ProcBell updates.

In the **Custom Sounds...** dialog, you can then either:
- type a bare filename like `meta.ogg` (auto-resolves to that folder), or
- type a full path like `Interface\AddOns\SomeOther\foo.ogg`, or
- type a numeric FileDataID (any sound from Wowhead's sound DB)

Find spell/aura IDs on Wowhead — the URL ends in the ID, e.g. `wowhead.com/spell=205021`.

## Releasing

Versions are published via GitHub Actions on tag push. The [BigWigs packager](https://github.com/BigWigsMods/packager) builds the zip and a `release.json`, which is what WowUp-CF reads.

```bash
# bump ## Version in procbell.toc, commit, then:
git tag v3.0.0
git push origin v3.0.0
```

The `Package and release` workflow runs and creates a GitHub Release with the addon zip attached. No CurseForge / Wago / WoWInterface credentials are required for GitHub-only distribution.

## License

No license declared. Add one (e.g. MIT) if you intend others to use or contribute.
