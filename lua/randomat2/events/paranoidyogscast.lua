local EVENT = {}

EVENT.Title = "Paranoid Yogscast"
EVENT.Description = "Periodically plays audio clips from Yogscast members implicating others in nefarious behaviors"
EVENT.id = "paranoidyogscast"
EVENT.StartSecret = true
EVENT.Categories = {"largeimpact"}

CreateConVar("randomat_paranoidyogscast_timer_min", 15, FCVAR_ARCHIVE, "The minimum time before the sound should play", 1, 120)
CreateConVar("randomat_paranoidyogscast_timer_max", 30, FCVAR_ARCHIVE, "The maximum time before the sound should play", 1, 120)
CreateConVar("randomat_paranoidyogscast_volume", 125, FCVAR_ARCHIVE, "The volume the sound should play at", 75, 180)

local BEN = "76561198005702755"
local DUNCAN = "76561197989857092"
local LEWIS = "76561197971116232"
local NILESY = "76561197987050685"
local PEDGUIN = "76561198035540223"
local RAVS = "76561197984355580"
local RYTHIAN = "76561197990096791"
local ZYLUS = "76561197964820404"

local clips = {
    {
        path = EVENT.id .. "/Duncan_BenYouBadBadBoy.mp3",
        players = { BEN, DUNCAN }
    },
    {
        path = EVENT.id .. "/Duncan_ItsLewisThatsDoneThis.mp3",
        players = { DUNCAN, LEWIS }
    },
    {
        path = EVENT.id .. "/Duncan_LewisDidItISawHim.mp3",
        players = { DUNCAN, LEWIS }
    },
    {
        path = EVENT.id .. "/Duncan_Scream.mp3",
        players = { DUNCAN }
    },
    {
        path = EVENT.id .. "/Duncan_WhatchaDoinZylus.mp3",
        players = { DUNCAN, ZYLUS }
    },
    {
        path = EVENT.id .. "/Lewis_BenJustDied.mp3",
        players = { BEN, LEWIS }
    },
    {
        path = EVENT.id .. "/Lewis_NilesysBad.mp3",
        players = { LEWIS, NILESY }
    },
    {
        path = EVENT.id .. "/Lewis_OhShitDuncanDied.mp3",
        players = { DUNCAN, LEWIS }
    },
    {
        path = EVENT.id .. "/Lewis_RavsDied.mp3",
        players = { LEWIS, RAVS }
    },
    {
        path = EVENT.id .. "/Lewis_RavsIsShootingMe.mp3",
        players = { LEWIS, RAVS }
    },
    {
        path = EVENT.id .. "/Nilesy_DontDoItRavs.mp3",
        players = { NILESY, RAVS }
    },
    {
        path = EVENT.id .. "/Nilesy_DuncanJustKilledLewis.mp3",
        players = { DUNCAN, LEWIS, NILESY }
    },
    {
        path = EVENT.id .. "/Pedguin_ItsLewis_BenDeath.mp3",
        players = { BEN, LEWIS, PEDGUIN }
    },
    {
        path = EVENT.id .. "/Ravs_IHearACreditPrinter.mp3",
        players = { RAVS }
    },
    {
        path = EVENT.id .. "/Ravs_LewisIsDoingBad.mp3",
        players = { LEWIS, RAVS }
    },
    {
        path = EVENT.id .. "/Ravs_PedsInTheTraitorRoom.mp3",
        players = { PEDGUIN, RAVS }
    },
    {
        path = EVENT.id .. "/Ravs_TheresANaughtyRythianDownHere.mp3",
        players = { RAVS, RYTHIAN }
    },
    {
        path = EVENT.id .. "/Rythian_Nonono.mp3",
        players = { RYTHIAN }
    },
    {
        path = EVENT.id .. "/Zylus_BenBenAughghh.mp3",
        players = { BEN, ZYLUS }
    },
    {
        path = EVENT.id .. "/Zylus_ItsLewis.mp3",
        players = { LEWIS, ZYLUS }
    }
}

function EVENT:Initialize()
    -- If the base Randomat is installed with the blerg sounds then we can include those too
    if file.IsDir("sound/blerg", "THIRDPARTY") then
        local blergs, _ = file.Find("sound/blerg/*.mp3", "THIRDPARTY")
        local blerg_files = {}
        for _, blerg in ipairs(blergs) do
            table.insert(blerg_files, "blerg/" .. blerg)
        end

        table.insert(clips, {
            path = blerg_files,
            players = { BEN }
        })
    end
end

local available = {}
function EVENT:StartTimer()
    local delay_min = GetConVar("randomat_paranoidyogscast_timer_min"):GetInt()
    local delay_max = math.max(delay_min, GetConVar("randomat_paranoidyogscast_timer_max"):GetInt())
    local delay = math.random(delay_min, delay_max)
    local volume = GetConVar("randomat_paranoidyogscast_volume"):GetInt()
    timer.Create("RdmtParanoidYogscastSoundTimer", delay, 1, function()
        -- Get a random player and their position
        local target = self:GetAlivePlayers(true)[1]
        local target_pos = target:GetPos()

        -- Move it around a little
        target_pos.x = target_pos.x + math.random(-5, 5)
        target_pos.y = target_pos.y + math.random(-5, 5)

        local idx = math.random(#available)
        local chosen_sound = available[idx]

        -- If this clip has multiple options, use a random one
        if type(chosen_sound) == "table" then
            chosen_sound = chosen_sound[math.random(#chosen_sound)]
        end

        sound.Play(chosen_sound, target_pos, volume, 100, 1)

        self:StartTimer()
    end)
end

function EVENT:Begin()
    local playerSid64s = {}
    for _, ply in ipairs(self:GetAlivePlayers()) do
        table.insert(playerSid64s, ply:SteamID64())
    end

    -- Find all the clips where all the tagged players are currently alive and connected
    -- Precache them, and save them for later
    for _, clip in pairs(clips) do
        local valid = true
        for _, sid64 in ipairs(clip.players) do
            if not table.HasValue(playerSid64s, sid64) then
                valid = false
                break
            end
        end

        if not valid then continue end

        -- If this is a list of sounds, cache each one
        if type(clip.path) == "table" then
            for _, c in ipairs(clip.path) do
                util.PrecacheSound(c)
            end
        else
            util.PrecacheSound(clip.path)
        end
        table.insert(available, clip.path)
    end

    self:StartTimer()
end

function EVENT:End()
    timer.Remove("RdmtParanoidYogscastSoundTimer")
    timer.Remove("RdmtParanoidYogscastShotTimer")
end

function EVENT:Condition()
    -- Gather all the IDs for the living players
    local playerSid64s = {}
    for _, ply in ipairs(self:GetAlivePlayers()) do
        table.insert(playerSid64s, ply:SteamID64())
    end

    local clipSid64s = {}
    local availableClipCount = 0
    -- Gather all the unique IDs mapped to the clips
    -- and also count how many clips have all of their tagged players available
    for _, clip in pairs(clips) do
        local valid = true
        for _, sid64 in ipairs(clip.players) do
            if not table.HasValue(clipSid64s, sid64) then
                table.insert(clipSid64s, sid64)
            end

            if not table.HasValue(playerSid64s, sid64) then
                valid = false
            end
        end

        if not valid then continue end

        availableClipCount = availableClipCount + 1
    end

    -- Count how many players that are tagged in the clips are available
    local foundPlyCount = 0
    for _, ply in ipairs(playerSid64s) do
        if table.HasValue(clipSid64s, ply:SteamID64()) then
            foundPlyCount = foundPlyCount + 1
        end
    end

    -- Make sure at least 3 people from the list of tagged clips are available
    -- and there are at least 5 different clips to play
    return foundPlyCount >= 3 and availableClipCount >= 5
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer_min", "timer_max", "volume"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)