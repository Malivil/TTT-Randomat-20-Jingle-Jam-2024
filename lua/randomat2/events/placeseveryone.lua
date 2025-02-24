local EVENT = {}

EVENT.Title = "Places, Everyone"
EVENT.Description = "Every time a player dies, everyone is teleported to different random spawn locations"
EVENT.id = "placeseveryone"
EVENT.Categories = {"deathtrigger", "smallimpact"}

function EVENT:Begin()
    local spawns = GetSpawnEnts(true)
    local spawnCount = table.Count(spawns)
    -- If we didn't find any spawns, get ALL of the spawns including the ones
    -- we don't normally use
    if spawnCount == 0 then
        spawns = GetSpawnEnts(true, true)
        spawnCount = table.Count(spawns)
    end

    local spawnIndex = 1
    self:AddHook("PostPlayerDeath", function()
        -- By randomizing players and looping through the spawns (which are more plentiful than players)
        -- we create a feeling of being moved to a random spawn each time while avoiding using the same spawn
        -- twice per death
        for _, ply in ipairs(self:GetAlivePlayers(true)) do
            local spawn = spawns[spawnIndex]:GetPos()
            ply:SetPos(spawn)

            -- Advance the chosen spawn, but be sure to wrap around when we pass the end of the table
            spawnIndex = spawnIndex + 1
            if spawnIndex > spawnCount then
                spawnIndex = 1
            end
        end
    end)
end

function EVENT:Condition()
    return type(GetSpawnEnts) == "function"
end

Randomat:register(EVENT)