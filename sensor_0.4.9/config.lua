
-- Do semi-random variation on the number of ticks delayed, helps spread out the load
SC_VARIATION = false

-- Tick delay of searching for new entities in range
SC_SEARCH_TICKS = 30
SC_PRESSUREFLOOR_TICKS = 60

-- Update tick delays, usually not very expensive, so can be short
local default_update_ticks = 20
SC_BELT_TICKS = default_update_ticks
SC_TRAIN_TICKS = default_update_ticks
SC_CAR_TICKS = default_update_ticks
SC_PLAYER_TICKS = default_update_ticks
SC_CHEST_TICKS = default_update_ticks
SC_ASSEMBLER_TICKS = default_update_ticks
SC_FURNACE_TICKS = default_update_ticks
SC_ROBOPORT_TICKS = 60
SC_ENERGY_UNIT_TICKS = 60
SC_TURRET_TICKS = default_update_ticks
SC_LAB_TICKS = default_update_ticks
SC_PIPES_TICKS = default_update_ticks
SC_DRILL_TICKS = 60

-- Searching distance limits for pressure floor
PRESSUREFLOOR_TILELIMIT_LENGTH = 25
PRESSUREFLOOR_TILELIMIT_SIDE = 24
