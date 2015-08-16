data:extend({
{
	type = "recipe",
	name = "directional-actuator",
	enabled = "false",
	ingredients =
	{
		{"copper-cable", 5},
		{"electronic-circuit", 5},
	},
	result = "directional-actuator"
},
{
	type = "item",
	name = "directional-actuator",
	icon = "__actuator__/graphics/actuator_icon.png",
	flags = { "goes-to-quickbar" },
	subgroup = "circuit-network",
	place_result="directional-actuator",
	order = "b[combinators]-e[directional-actuator]",
	stack_size= 50,
},

	{	
		type = "inserter",
		name = "directional-actuator",
		icon = "__actuator__/graphics/actuator_icon.png",
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "directional-actuator"},
		max_health = 100,
		render_layer = "object",
		corpse = "small-remnants",
		filter_count = 1,
		resistances = 
		{
			{
				type = "fire",
				percent = 90
			}
		},
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		pickup_position = {0, -0.2},
		insert_position = {0, 1.2},
		energy_per_movement = 200,
		energy_per_rotation = 200,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			drain = "0.4kW",
		},
		extension_speed = 0.7,
		programmable = true,
		rotation_speed = 0.35,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		hand_base_picture = { filename = "__actuator__/graphics/actuator.png", width = 0, height = 0 },
		hand_closed_picture = { filename = "__actuator__/graphics/actuator.png", width = 0, height = 0 },
		hand_open_picture = { filename = "__actuator__/graphics/actuator.png", width = 0, height = 0 },
		hand_base_shadow = { filename = "__actuator__/graphics/actuator.png", width = 0, height = 0 },
		hand_closed_shadow = { filename = "__actuator__/graphics/actuator.png", width = 0, height = 0 },
		hand_open_shadow = { filename = "__actuator__/graphics/actuator.png", width = 0, height = 0 },
		platform_picture =
		{
			sheet=
			{
				filename = "__actuator__/graphics/actuator.png",
				width = 72,
				height = 46,
				frame_count = 4,
				shift = {0, 0},
			}
		},

		circuit_wire_connection_point =
		{
		  shadow =
		  {
			red = {0.2, 0},
			green = {0.2, 0}
		  },
		  wire =
		  {
			red = {0.0, -0.2},
			green = {0.0, -0.2}
		  }
		},
		circuit_wire_max_distance = 7.5,
		uses_arm_movement = "basic-inserter"
	},
	{
		type = "simple-entity",
		name = "indicator-green",
		flags = {"placeable-off-grid"},
		drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
		render_layer = "object",
		max_health = 0,
		pictures =
		{
			{
				filename = "__actuator__/graphics/greenlamp.png",
				width = 11,
				height = 11,
				shift = {0,0},
			},
		}
	},
	{
		type = "simple-entity",
		name = "indicator-orange",
		flags = {"placeable-off-grid"},
		drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
		render_layer = "object",
		max_health = 0,
		pictures =
		{
			{
				filename = "__actuator__/graphics/orangelamp.png",
				width = 11,
				height = 11,
				shift = {0,0},
			},
		}
	},
	{
		type = "simple-entity",
		name = "indicator-red",
		flags = {"placeable-off-grid"},
		drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
		render_layer = "object",
		max_health = 0,
		pictures =
		{
			{
				filename = "__actuator__/graphics/redlamp.png",
				width = 11,
				height = 11,
				shift = {0,0},
			},
		}
	},
})

table.insert(data.raw["technology"]["circuit-network"].effects, { type = "unlock-recipe", recipe = "directional-actuator"})
