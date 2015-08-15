local nullpic = {
	filename = "__base__/graphics/entity/combinator/decider-symbols.png",
	width = 0,
	height = 0,
	frame_count = 1,
	shift = {0,0},
}
local nullsymbols = {
	north = nullpic,
	east = nullpic,
	south = nullpic,
	west = nullpic,
}
local nullconnection = {
	wire =
	{
		green = {0, 0}, red = {0, 0}
	},
	shadow =
	{
		green = {0, 0}, red = {0, 0}
	}
}
local nullconnections = {
	nullconnection, 
	nullconnection, 
	nullconnection, 
	nullconnection,
}

data:extend({
{
	type = "item-subgroup",
	name = "virtual-signal-sensor",
	group = "signals",
	order = "z"
},
{
	type = "recipe",
	name = "directional-sensor",
	enabled = "false",
	ingredients =
	{
		{"copper-cable", 5},
		{"electronic-circuit", 5},
	},
	result = "directional-sensor"
},
{
	type = "item",
	name = "belt-left",
	icon = "__sensor__/graphics/belt-left-icon.png",
	flags = {"goes-to-main-inventory"},
	subgroup = "virtual-signal-sensor",
	order = "a",
	stack_size = 1000
},
{
	type = "item",
	name = "belt-right",
	icon = "__sensor__/graphics/belt-right-icon.png",
	flags = {"goes-to-main-inventory"},
	subgroup = "virtual-signal-sensor",
	order = "b",
	stack_size = 1000
},
{
	type = "item",
	name = "energy-unit",
	icon = "__sensor__/graphics/energy-unit-icon.png",
	flags = {"goes-to-main-inventory"},
	subgroup = "virtual-signal-sensor",
	order = "c",
	stack_size = 10000
},
{
	type = "item",
	name = "detected-player",
	icon = "__sensor__/graphics/player-icon.png",
	flags = {"goes-to-main-inventory"},
	subgroup = "virtual-signal-sensor",
	order = "d",
	stack_size = 1000
},
{
	type = "item",
	name = "detected-alien",
	icon = "__base__/graphics/icons/medium-biter.png",
	flags = {"goes-to-main-inventory"},
	subgroup = "virtual-signal-sensor",
	order = "e",
	stack_size = 1000
},
{
	type = "item",
	name = "detected-car",
	icon = "__sensor__/graphics/car-icon.png",
	flags = {"goes-to-main-inventory"},
	subgroup = "virtual-signal-sensor",
	order = "f",
	stack_size = 1000
},
{
	type = "item",
	name = "detected-train",
	icon = "__sensor__/graphics/train-icon.png",
	flags = {"goes-to-main-inventory"},
	subgroup = "virtual-signal-sensor",
	order = "g",
	stack_size = 1000
},
{
	type = "item",
	name = "directional-sensor",
	icon = "__sensor__/graphics/sensor_icon.png",
	flags = { "goes-to-quickbar" },
	subgroup = "circuit-network",
	place_result="directional-sensor",
	order = "b[combinators]-c[directional-sensor]",
	stack_size= 50,
},
  {
    type = "decider-combinator",
    name = "directional-sensor",
    icon = "__sensor__/graphics/sensor_icon.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "directional-sensor"},
    max_health = 50,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.85}, {0.35, 0.85}},
    selection_box = {{-0.5, 0}, {0.5, 1}},

    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "400W"
    },
    active_energy_usage = "400W",

    sprites =
    {
      north =
      {
        filename = "__sensor__/graphics/sensor.png",
        width = 104,
        height = 84,
        frame_count = 1,
        shift = {-0.0625, 0.0625},
      },
      east =
      {
        filename = "__sensor__/graphics/sensor.png",
        x = 104,
        width = 104,
        height = 84,
        frame_count = 1,
        shift = {0.4375, 0.5625},
      },
      south =
      {
        filename = "__sensor__/graphics/sensor.png",
        x = 208,
        width = 104,
        height = 84,
        frame_count = 1,
        shift = {-0.0625, 0.0625},
      },
      west =
      {
        filename = "__sensor__/graphics/sensor.png",
        x = 312,
        width = 104,
        height = 84,
        frame_count = 1,
        shift = {0.4375, 0.5625},
      }
    },

    activity_led_sprites = nullsymbols,

    equal_symbol_sprites = nullsymbols,
    greater_symbol_sprites = nullsymbols,
    less_symbol_sprites = nullsymbols,

    input_connection_bounding_box = {{0,0}, {0,0}},
    output_connection_bounding_box = {{0,0}, {0,0}},

    input_connection_points = nullconnections, 
    output_connection_points = nullconnections,
    circuit_wire_max_distance = 7.5
  },
{
	type = "smart-container",
	name = "directional-sensor-output",
	icon = "__sensor__/graphics/sensor_icon.png",
	minable = {hardness = 0.2, mining_time = 0.5, result = "directional-sensor"},
    max_health = 0,
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    inventory_size = 10000,
    picture =
    {
      filename = "__base__/graphics/entity/smart-chest/smart-chest.png",
      priority = "extra-high",
      width = 0,
      height = 0,
      shift = {0,0}
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.5,0},
        green = {0.5,0}
      },
      wire =
      {
        red = {0,-0.5},
        green = {0,-0.5}
      }
    },
    circuit_wire_max_distance = 7.5
},
})

table.insert(data.raw["technology"]["circuit-network"].effects, { type = "unlock-recipe", recipe = "directional-sensor"})
