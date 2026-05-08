local addonName, ns = ...

local function loadDB()
    if type(ProcBellDB) ~= "table" then ProcBellDB = {} end
    if type(ProcBellDB.spellBindings) ~= "table" then ProcBellDB.spellBindings = {} end
    if type(ProcBellDB.auraBindings)  ~= "table" then ProcBellDB.auraBindings  = {} end
    if type(ProcBellDB.customSounds)  ~= "table" then ProcBellDB.customSounds  = {} end

    -- First-run seed: bind Ray of Frost to the bundled sound.
    if next(ProcBellDB.spellBindings) == nil and next(ProcBellDB.auraBindings) == nil then
        ProcBellDB.spellBindings[205021] = {
            name = "ProcBell (custom)",
            kind = "file",
            source = "Interface\\AddOns\\procbell\\procbell.ogg",
        }
    end
end

local function bindingTable(triggerType)
    if triggerType == "aura" then return ProcBellDB.auraBindings end
    return ProcBellDB.spellBindings
end

function ns.PlayBoundSound(binding)
    if not binding then return end
    if binding.kind == "file" then
        return PlaySoundFile(binding.source, "Master")
    elseif binding.kind == "soundkit" then
        return PlaySound(binding.source, "Master")
    end
end

function ns.GetBinding(triggerType, spellID)
    local t = bindingTable(triggerType)
    return t and t[spellID] or nil
end

function ns.SetBinding(triggerType, spellID, sound)
    local t = bindingTable(triggerType)
    if not t then return end
    t[spellID] = {
        name = sound.name,
        kind = sound.kind,
        source = sound.source,
    }
end

function ns.RemoveBinding(triggerType, spellID)
    local t = bindingTable(triggerType)
    if t then t[spellID] = nil end
end

function ns.AddBinding(triggerType, spellID)
    local t = bindingTable(triggerType)
    if not t or t[spellID] ~= nil then return end
    local default = ns.sounds and ns.sounds[1]
    if default then ns.SetBinding(triggerType, spellID, default) end
end

function ns.IterBindings(triggerType)
    local t = bindingTable(triggerType)
    return pairs(t or {})
end

-- Custom sounds (user-added, persisted in SavedVariables).
-- A "source" may be a string path or a numeric FileDataID; PlaySoundFile accepts both.
local function normalizeSource(raw)
    if type(raw) == "number" then return raw end
    if type(raw) ~= "string" then return nil end
    raw = raw:match("^%s*(.-)%s*$") or raw
    if raw == "" then return nil end
    local n = tonumber(raw)
    if n then return n end
    -- Convenience: bare filename like "meta.ogg" gets prefixed to a sibling
    -- folder that survives ProcBell updates. The user must create this folder
    -- themselves; addons can't write to disk. WoW reads any file under
    -- Interface\AddOns regardless of whether the folder is a registered addon.
    if not raw:find("[\\/]") then
        return "Interface\\AddOns\\ProcBell_UserSounds\\" .. raw
    end
    return raw
end

function ns.AddCustomSound(name, rawSource)
    if type(name) ~= "string" then return false end
    name = name:match("^%s*(.-)%s*$") or name
    if name == "" then return false end
    local source = normalizeSource(rawSource)
    if source == nil then return false end
    ProcBellDB.customSounds[#ProcBellDB.customSounds + 1] = { name = name, source = source }
    return true
end

function ns.RemoveCustomSound(index)
    if type(index) == "number" then
        table.remove(ProcBellDB.customSounds, index)
    end
end

function ns.GetCustomSounds()
    return ProcBellDB and ProcBellDB.customSounds or {}
end

-- Combined list of built-in registry + user custom sounds, used by the picker.
function ns.GetAllSounds()
    local out = {}
    if ns.sounds then
        for _, s in ipairs(ns.sounds) do
            out[#out + 1] = s
        end
    end
    if ProcBellDB and ProcBellDB.customSounds then
        for _, s in ipairs(ProcBellDB.customSounds) do
            out[#out + 1] = { name = s.name, kind = "file", source = s.source }
        end
    end
    return out
end

function ns.GetSpellNameAndIcon(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if type(info) == "table" then
            return info.name, info.iconID
        end
    end
    if GetSpellInfo then
        local n, _, i = GetSpellInfo(spellID)
        return n, i
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            loadDB()
            f:UnregisterEvent("ADDON_LOADED")
            f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
            f:RegisterUnitEvent("UNIT_AURA", "player")
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, _, spellID = ...
        local binding = ns.GetBinding("cast", spellID)
        if binding then ns.PlayBoundSound(binding) end
    elseif event == "UNIT_AURA" then
        local _, info = ...
        if type(info) ~= "table" then return end
        if info.isFullUpdate then return end
        local added = info.addedAuras
        if not added then return end
        for _, aura in ipairs(added) do
            local sid = aura and aura.spellId
            if sid then
                local binding = ns.GetBinding("aura", sid)
                if binding then ns.PlayBoundSound(binding) end
            end
        end
    end
end)

SLASH_PROCBELL1 = "/procbell"
SLASH_PROCBELL2 = "/pb"
SlashCmdList.PROCBELL = function()
    if ns.OpenUI then ns.OpenUI() end
end
