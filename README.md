# ProcBell

A small World of Warcraft addon that plays a sound when you cast specific spells or gain specific auras. Useful for proc cues, cooldown alerts, ability reminders, etc.

## Features

- Play any sound when you successfully cast a spell (e.g. Ray of Frost — spell ID `205021`)
- Play any sound when an aura newly appears on you (e.g. Vengeance Metamorphosis — spell ID `187827`)
- Pick from a curated list of WoW built-in SoundKits + a bundled custom sound (`procbell.ogg`)
- Reads the SharedMedia (LibSharedMedia-3.0) sound registry — every sound any other addon registers shows up in the dropdown automatically
- Settings persist across sessions per character

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

Find spell/aura IDs on Wowhead — the URL ends in the ID, e.g. `wowhead.com/spell=205021`.

## Adding custom sounds

ProcBell does not store custom sounds itself — the addon folder gets replaced on every update, so anything dropped in there would vanish. Instead, ProcBell embeds **LibSharedMedia-3.0** and reads its registry. Any sound registered there from any other addon shows up in ProcBell's dropdown automatically.

The standard companion addons for adding your own files are:

- [**SharedMedia**](https://www.curseforge.com/wow/addons/sharedmedia) — the parent addon, ships ~50 default sounds/fonts/textures, provides the in-game browser.
- [**SharedMedia MyMedia**](https://www.curseforge.com/wow/addons/sharedmedia_mymedia) — a stub addon with `sound\`, `font\`, and `statusbar\` folders intended for *your* custom files. Survives ProcBell updates because no addon manager owns it.

### Step by step

1. Install both **SharedMedia** and **SharedMedia MyMedia** from the links above (search for them in WowUp-CF / CurseForge / Wago — they both come from the catalog, no URL install needed).
2. Drop your `.ogg` file into:
   ```
   World of Warcraft\_retail_\Interface\AddOns\SharedMedia_MyMedia\sound\
   ```
3. **Register the file with LSM.** This is the part that's easy to miss — just dropping the file is *not* enough; LSM needs an explicit `Register` call. Two ways:

   **Option A: run the included batch script** (Windows). SharedMedia_MyMedia ships with a `.bat` file that scans the `sound\` folder and writes the `LSM:Register(...)` lines into `MyMedia.lua` for you. Double-click it after adding new files. Tip: if it doesn't seem to register everything on the first run, run it a second time — sometimes it needs the second pass to pick up everything.

   **Option B: edit `MyMedia.lua` by hand**. Open `Interface\AddOns\SharedMedia_MyMedia\MyMedia.lua` in a text editor and add a line per sound:
   ```lua
   LSM:Register("sound", "MyAlert", [[Interface\AddOns\SharedMedia_MyMedia\sound\my-alert.ogg]])
   ```
   - First arg is always `"sound"`.
   - Second arg is the display name shown in dropdowns.
   - Third arg is the full path. The `[[...]]` syntax means you don't have to escape backslashes.

4. `/reload` in-game. The sound now appears in ProcBell's dropdown — and in every other LSM-aware addon (WeakAuras, BigWigs, Plater, Details, etc.).

### Verifying

If a sound isn't showing up, run this in chat to dump everything LSM has registered:

```
/run for _, n in ipairs(LibStub("LibSharedMedia-3.0"):List("sound")) do print(n) end
```

If your sound's name isn't in the printed list, it didn't register — re-run the .bat or fix the line in `MyMedia.lua`. If it *is* in the list but missing from ProcBell's dropdown, that's a ProcBell bug — open an issue.

## Releasing

Versions are published via GitHub Actions on tag push. The [BigWigs packager](https://github.com/BigWigsMods/packager) builds the zip, embeds the bundled libraries declared in `.pkgmeta`, and writes a `release.json` that WowUp-CF reads.

```bash
git tag v1.0.1
git push origin v1.0.1
```

Or just push to `main` and the auto-tag workflow bumps the patch automatically.

## License

No license declared. Add one (e.g. MIT) if you intend others to use or contribute.
