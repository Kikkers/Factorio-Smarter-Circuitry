data:extend({
  {
    type = "recipe",
    name = "pressure-floor",
    energy_required = 1,
    enabled = false,
    ingredients =
    {
      {"concrete", 1},
      {"steel-plate", 1},
      {"electronic-circuit", 2},
    },
    result= "pressure-floor",
  },
  {
    type = "item",
    name = "pressure-floor",
    icon = "__pressure-floor__/graphics/pad-icon.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "terrain",
    order = "c[pressure-floor]",
    stack_size = 100,
    place_as_tile =
    {
      result = "pressure-floor",
      condition_size = 1,
      condition = { "water-tile" }
    }
  },
  })

  
local pressurefloor = util.table.deepcopy(data.raw["tile"]["concrete"])
pressurefloor.name = "pressure-floor"
pressurefloor.minable.result = "pressure-floor"
pressurefloor.variants.main[1].picture = "__pressure-floor__/graphics/pad1.png"
pressurefloor.variants.main[2].picture = "__pressure-floor__/graphics/pad2.png"
pressurefloor.variants.main[3].picture = "__pressure-floor__/graphics/pad4.png"
data.raw[pressurefloor.type][pressurefloor.name] = pressurefloor

local activefloor = util.table.deepcopy(data.raw["tile"]["concrete"])
activefloor.name = "active-pressure-floor"
activefloor.minable.result = "pressure-floor"
activefloor.variants.main[1].picture = "__pressure-floor__/graphics/pad-active1.png"
activefloor.variants.main[2].picture = "__pressure-floor__/graphics/pad-active2.png"
activefloor.variants.main[3].picture = "__pressure-floor__/graphics/pad-active4.png"
data.raw[activefloor.type][activefloor.name] = activefloor

table.insert(data.raw["technology"]["concrete"].effects, { type = "unlock-recipe", recipe = "pressure-floor"})
