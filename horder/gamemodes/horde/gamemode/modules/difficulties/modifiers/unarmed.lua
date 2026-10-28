local DIFF = "UNARMED"
local function V(key, default)
    return HORDE.DiffCfg(DIFF, key, default)
end

HORDE:RegisterDifficulty({
    Name    = DIFF,
    Index   = 6,
    IsModifier = true,

    IsUnarmed    = true,
    MaxWaves     = 15,

    -- Fixed 5s between zombie spawns. It used to start at 1s and drop by
    -- 0.25s every 5 waves.
    SpawnInterval            = V("SpawnInterval", 5),
    SpawnIntervalWaveStep    = V("SpawnIntervalWaveStep", 0),
    SpawnIntervalWaveAmount  = V("SpawnIntervalWaveAmount", 0.25),
    SpawnIntervalWaveCap     = V("SpawnIntervalWaveCap", 0.25),
})
