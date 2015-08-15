data:extend({
  {
    type = "recipe",
    name = "micro-accumulator",
    energy_required = 0.5,
    enabled = false,
    ingredients =
    {
      {"iron-plate", 1},
      {"battery", 1}
    },
    result = "micro-accumulator"
  },
  {
    type = "item",
    name = "micro-accumulator",
    icon = "__micro-accumulator__/graphics/micro-accumulator-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "e[accumulator]-z[micro-accumulator]",
    place_result = "micro-accumulator",
    stack_size = 50
  },
  {
    type = "accumulator",
    name = "micro-accumulator",
    icon = "__micro-accumulator__/graphics/micro-accumulator-icon.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "micro-accumulator"},
    max_health = 20,
    corpse = "small-remnants",
    collision_box = {{-0.17, -0.17}, {0.17, 0.17}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "10kJ",
      usage_priority = "terciary",
      input_flow_limit = "1GW",
      output_flow_limit = "1GW"
    },
    picture =
    {
      filename = "__micro-accumulator__/graphics/micro-accumulator.png",
      priority = "extra-high",
      width = 48,
      height = 40,
      shift = {0.25, 0},
    },
    charge_animation =
    {
      filename = "__micro-accumulator__/graphics/micro-accumulator.png",
      width = 48,
      height = 40,
      line_length = 1,
      frame_count = 1,
      shift = {0.25, 0},
      animation_speed = 0.5
    },
    charge_cooldown = 0,
    charge_light = {intensity = 0, size = 0},
    discharge_animation =
    {
      filename = "__micro-accumulator__/graphics/micro-accumulator.png",
      width = 48,
      height = 40,
      line_length = 1,
      frame_count = 1,
      shift = {0.25, 0},
      animation_speed = 0.5
    },
    discharge_cooldown = 0,
    discharge_light = {intensity = 0, size = 0},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.3 },
--    working_sound =
--    {
--      sound = 
--      {
--        filename = "__base__/sound/accumulator-working.ogg",
--        volume = 1
--      },
--      idle_sound = {
--        filename = "__base__/sound/accumulator-idle.ogg",
--        volume = 0.4
--      },
--      max_sounds_per_type = 5
--    },
  },
})

table.insert(data.raw["technology"]["electric-energy-accumulators-1"].effects, { type = "unlock-recipe", recipe = "micro-accumulator"})
