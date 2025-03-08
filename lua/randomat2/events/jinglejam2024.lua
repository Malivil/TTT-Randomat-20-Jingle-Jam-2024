local math = math
local string = string
local util = util

local StringFind = string.find
local StringReplace = string.Replace
local MathCeil = math.ceil

local EVENT = {}

EVENT.Title = "Jingle Jam 2024"
EVENT.Description = "You've joined a jam band! Each player was assigned a random instrument\nShoot to play, aim up and down to change notes"
EVENT.id = "jinglejam2024"
EVENT.Type = EVENT_TYPE_GUNSOUNDS
EVENT.Categories = {"fun", "smallimpact"}

-- Instruments toward the start of this list will be used more often than the ones at the end
local sounds = {
    guitar = {
        "guitarc.mp3", "guitard.mp3", "guitare.mp3", "guitarf.mp3", "guitarg.mp3", "guitara.mp3",
        "guitarheavyelow.mp3", "guitarheavya.mp3", "guitarheavyg.mp3", "guitarheavyehigh.mp3", "guitarheavypluck.mp3", "guitarheavypluck2.mp3"
    },
    ["bass guitar"] = {
        "bassc.mp3", "bassd.mp3", "basse.mp3", "bassf.mp3", "bassg.mp3", "bassa.mp3",
        "electricbassc.mp3", "electricbassd.mp3", "electricbasse.mp3", "electricbassf.mp3", "electricbassg.mp3", "electricbassb.mp3"
    },
    drums = {
        "kick.mp3", "kick2.mp3", "concerttom.mp3", "floortom.mp3", "tom.mp3", "snare.mp3",
        "snare2.mp3", "hihat.mp3", "cymbalcrash.mp3", "cymbalshort.mp3", "cymbalmedium.mp3", "cymballong.mp3"
    },
    ["acoustic guitar"] = {
        "acousticc.mp3", "acousticd.mp3", "acoustice.mp3", "acousticf.mp3", "acousticg.mp3", "acoustica.mp3",
        "nylonbminor.mp3", "nylondflatminor.mp3", "nylonemajor.mp3", "nylonfsharpmaj9.mp3", "nylonfsharpminor.mp3", "nylonaflatmajor.mp3"
    },
    piano = {
        "pianoa.mp3", "pianogsharp.mp3", "pianobflat.mp3", "pianob.mp3", "pianoc.mp3", "pianocsharp.mp3",
        "pianod.mp3", "pianoeflat.mp3", "pianoe.mp3", "pianof.mp3", "pianofsharp.mp3", "pianog.mp3"
    }
}
local soundsFolder = {}
local ignorePaths = {
    ".*weapons/.*explode.*%..*", ".*weapons/.*beep.*%..*",
    ".*weapons/.*out%..*", ".*weapons/.*in%..*",
    ".*weapons/.*reload.*%..*", ".*weapons/.*deploy.*%..*",
    ".*weapons/.*insertshell.*%..*", ".*weapons/.*selectorswitch.*%..*",
    ".*weapons/.*fetchmag.*%..*", ".*weapons/.*magslap.*%..*",
    ".*weapons/.*beltjingle.*%..*", ".*weapons/.*beltalign.*%..*",
    ".*weapons/.*lidopen.*%..*", ".*weapons/.*lidclose.*%..*",
    ".*weapons/.*coverup.*%..*", ".*weapons/.*coverdown.*%..*",
    ".*weapons/.*rattle.*%..*", ".*weapons/.*slidepull.*%..*",
    ".*weapons/.*slideback.*%..*", ".*weapons/.*sliderelease.*%..*",
    ".*weapons/.*bolt.*%..*", ".*weapons/.*shotgun_shell.*%..*",
    ".*weapons/.*empty.*%..*", ".*weapons/.*zoom.*%..*"
}

local function GetWeaponSound(ply, pitch)
    local instrument = ply:GetNWString("RdmtJingleJam2024Instrument", "")
    if #instrument == 0 then return end

    local index = MathCeil(pitch / 15)
    return EVENT.id .. "/" .. soundsFolder[instrument] ..  "/" .. sounds[instrument][index]
end

local function ShouldIgnoreSound(soundName)
    -- If this isn't a weapon sound, ignore it
    if not StringFind(soundName, "weapon") then return true end

    -- If any of these patterns match the sound name, ignore it
    for _, pattern in ipairs(ignorePaths) do
        if string.find(soundName, pattern) then return true end
    end

    return false
end

function EVENT:Initialize()
    local instruments = table.GetKeys(sounds)
    for _, i in pairs(instruments) do
        soundsFolder[i] = StringReplace(i, " ", "")
    end

    for _, i in pairs(instruments) do
        local instrumentFolder = soundsFolder[i]
        for _, s in ipairs(sounds[i]) do
            util.PrecacheSound(instrumentFolder .. "/" .. s)
        end
    end
end

function EVENT:Begin()
    local currentInstrument = 1
    local instruments = table.GetKeys(sounds)
    local maxInstruments = table.Count(instruments)
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        local instrument = instruments[currentInstrument]
        ply:SetNWString("RdmtJingleJam2024Instrument", instrument)

        -- Tell the player their instrument
        timer.Simple(0.1, function()
            Randomat:PrintMessage(ply, MSG_PRINTBOTH, "You have the " .. instrument)
        end)

        currentInstrument = currentInstrument + 1
        -- Loop through the instruments repeatedly
        if currentInstrument > maxInstruments then
            currentInstrument = 1
        end
    end

    self:AddHook("EntityEmitSound", function(data)
        if ShouldIgnoreSound(data.SoundName:lower()) then return end
        if not IsPlayer(data.Entity) then return end

        local aim = data.Entity:EyeAngles()
        aim:Normalize()

        -- Negate the pitch because in GMod looking down is positive and looking up is negative
        local pitch = -aim.pitch
        -- Normalize the pitch to within 0-180 for easier indexing
        pitch = pitch + 90

        local chosen_sound = GetWeaponSound(data.Entity, pitch)
        data.SoundName = chosen_sound
        return true
    end)
end

Randomat:register(EVENT)