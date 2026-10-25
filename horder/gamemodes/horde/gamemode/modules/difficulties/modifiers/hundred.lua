local DIFF = "HUNDRED"
local function V(key, default)
    return HORDE.DiffCfg(DIFF, key, default)
end

HORDE:RegisterDifficulty({
    Name    = DIFF,
    Index   = 7,
    IsModifier = true,

    IsHundred    = true,
    MaxWaves     = 100,
    ScalePerWave = 0.025,

    SpawnInterval            = V("SpawnInterval", 1),
    SpawnIntervalWaveStep    = V("SpawnIntervalWaveStep", 5),
    SpawnIntervalWaveAmount  = V("SpawnIntervalWaveAmount", 0.075),
    SpawnIntervalWaveCap     = V("SpawnIntervalWaveCap", 0.25),

    AdditionalEnemiesPerSpawn = V("AdditionalEnemiesPerSpawn", 0),
    EnemiesPerSpawnWaveStep   = V("EnemiesPerSpawnWaveStep", 10),
    EnemiesPerSpawnWaveAmount = V("EnemiesPerSpawnWaveAmount", 1),
    EnemiesPerSpawnWaveCap    = V("EnemiesPerSpawnWaveCap", 4),

    -- Wave size curve (multiplies the per-wave enemy total).
    -- Waves 1..CountEarlyEndWave use CountEarlyMult, then a linear ramp up to
    -- CountRampEndMult by CountFinalWave - 1, and CountFinalMult from CountFinalWave on.
    CountEarlyEndWave = V("CountEarlyEndWave", 60),
    CountEarlyMult    = V("CountEarlyMult", 0.5),
    CountRampEndMult  = V("CountRampEndMult", 1),
    CountFinalWave    = V("CountFinalWave", 90),
    CountFinalMult    = V("CountFinalMult", 2),

    -- Player scaling of the wave total: the first PlayerScaleFullPlayers each add
    -- a full share, every player after that adds PlayerScaleExtraShare.
    PlayerScaleFullPlayers = V("PlayerScaleFullPlayers", 4),
    PlayerScaleExtraShare  = V("PlayerScaleExtraShare", 0.5),

})
