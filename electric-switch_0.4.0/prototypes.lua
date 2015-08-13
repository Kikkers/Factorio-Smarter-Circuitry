wire_pictures = {
	copper =
	{
		filename = "__base__/graphics/entity/small-electric-pole/copper-wire.png",
		priority = "extra-high-no-scale",
		width = 224,
		height = 46
	},
	green =
	{
		filename = "__base__/graphics/entity/small-electric-pole/green-wire.png",
		priority = "extra-high-no-scale",
		width = 224,
		height = 46
	},
	radius =
	{
		filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
		width = 12,
		height = 12
	},
	red =
	{
		filename = "__base__/graphics/entity/small-electric-pole/red-wire.png",
		priority = "extra-high-no-scale",
		width = 224,
		height = 46
	},
	shadow =
	{
		filename = "__base__/graphics/entity/small-electric-pole/wire-shadow.png",
		priority = "extra-high-no-scale",
		width = 224,
		height = 46
	}
}

data:extend({
	{
		type = "recipe",
		name = "electric-switch",
		energy_required = 2,
		enabled = "false",
		ingredients =
		{
			{"steel-plate", 4},
			{"copper-plate", 4},
			{"electronic-circuit", 4},
		},
		result = "electric-switch"
	},
	{
		type = "item",
		name = "electric-switch",
		icon = "__electric-switch__/graphics/switch-icon.png",
		flags = {"goes-to-quickbar"},
		subgroup = "circuit-network",
		place_result = "electric-switch",
		order = "b[combinators]-c[electric-switch]",
		stack_size = 50
	},
	{
		type = "simple-entity",
		name = "switch-deco-vertical",
		flags = {"placeable-off-grid"},
		drawing_box = {{-1.2, -1.2}, {1.2, 1.2}},
		render_layer = "object",
		max_health = 1,
		pictures =
		{
			{
				filename = "__electric-switch__/graphics/switch.png",
				width = 160,
				height = 143,
				shift = {1.15, -1.0},
			},
		}
	},
	{
		type = "simple-entity",
		name = "switch-deco-horizontal",
		flags = {"placeable-off-grid"},
		drawing_box = {{-1.2, -1.2}, {1.2, 1.2}},
		render_layer = "object",
		max_health = 1,
		pictures =
		{
			{
				filename = "__electric-switch__/graphics/switch.png",
				x = 160,
				width = 160,
				height = 143,
				shift = {1.15, -1.0},
			},
		}
	},


	{	
		type = "inserter",
		name = "electric-switch",
		icon = "__electric-switch__/graphics/switch-icon.png",
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "electric-switch"},
		max_health = 100,
		render_layer = "object",
		corpse = "medium-remnants",
		filter_count = 1,
		resistances = 
		{
			{
				type = "fire",
				percent = 90
			}
		},
		collision_box = {{-0.34, -1.10}, {0.34, 1.10}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		drawing_box = {{-1.2, -1.2}, {1.2, 1.2}},
		pickup_position = {-0.2, -0.8},
		insert_position = {0.2, 0.8},
		energy_per_movement = 200,
		energy_per_rotation = 200,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			drain = "0.1kW",
		},
		extension_speed = 0.7,
		programmable = true,
		rotation_speed = 0.35,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		hand_base_picture = { filename = "__electric-switch__/graphics/switch.png", width = 0, height = 0 },
		hand_closed_picture = { filename = "__electric-switch__/graphics/switch.png", width = 0, height = 0 },
		hand_open_picture = { filename = "__electric-switch__/graphics/switch.png", width = 0, height = 0 },
		hand_base_shadow = { filename = "__electric-switch__/graphics/switch.png", width = 0, height = 0 },
		hand_closed_shadow = { filename = "__electric-switch__/graphics/switch.png", width = 0, height = 0 },
		hand_open_shadow = { filename = "__electric-switch__/graphics/switch.png", width = 0, height = 0 },
		platform_picture =
		{
			sheet=
			{
				filename = "__electric-switch__/graphics/switch.png",
				priority = "extra-high",
				width = 160,
				height = 143,
				frames = 2,
				shift = {1.15, -1.0},
			}
		},

		circuit_wire_connection_point =
		{
		  shadow =
		  {
			red = {0.5, 0},
			green = {0.5, 0}
		  },
		  wire =
		  {
			red = {0, -0.5},
			green = {0, -0.5}
		  }
		},
		circuit_wire_max_distance = 7.5,
		uses_arm_movement = "basic-inserter"
	},
	
	{
		type = "electric-pole",
		name = "west-node",
		icon = "__electric-switch__/graphics/switch-icon.png",
		flags = {"placeable-off-grid"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "electric-switch"},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		max_health = 0,
		maximum_wire_distance = 5,
		supply_area_distance = 1.5,
		pictures =
		{
			filename = "__electric-switch__/graphics/switch.png",
			priority = "high",
			width = 0,--123,
			height = 0,--124,
			axially_symetric = false,
			direction_count = 1,
			shift = {1.4, -1.1}
		},
		connection_points =
		{
			{
				shadow =
				{
					copper = {2.3, 0.0},
					red =	 {2.3, -0.25 },
					green =	 {2.3, 0.25 }
				},
				wire =
				{
					copper = {-0.15, -2.15},
					red =	 {-0.15, -2.40 },
					green =	 {-0.15, -1.90 }
				}
			},
		},
		copper_wire_picture = wire_pictures.copper,
		green_wire_picture = wire_pictures.green,
		radius_visualisation_picture = wire_pictures.radius,
		red_wire_picture = wire_pictures.red,
		wire_shadow_picture = wire_pictures.shadow,
	},

	{
		type = "electric-pole",
		name = "east-node",
		icon = "__electric-switch__/graphics/switch-icon.png",
		flags = {"placeable-off-grid"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "electric-switch"},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		max_health = 0,
		maximum_wire_distance = 5,
		supply_area_distance = 1.5,
		pictures =
		{
			filename = "__electric-switch__/graphics/switch.png",
			priority = "high",
			width = 0,--123,
			height = 0,--124,
			axially_symetric = false,
			direction_count = 1,
			shift = {1.4, -1.1}
		},
		connection_points =
		{
			{
				shadow =
				{
					copper = {2.3, 0.0},
					red =	 {2.3, -0.25 },
					green =	 {2.3, 0.25 }
				},
				wire =
				{
					copper = {0.08, -2.15},
					red =	 {0.08, -2.40 },
					green =	 {0.08, -1.90 }
				}
			},
		},
		copper_wire_picture = wire_pictures.copper,
		green_wire_picture = wire_pictures.green,
		radius_visualisation_picture = wire_pictures.radius,
		red_wire_picture = wire_pictures.red,
		wire_shadow_picture = wire_pictures.shadow,
	},

	{
		type = "electric-pole",
		name = "north-node",
		icon = "__electric-switch__/graphics/switch-icon.png",
		flags = {"placeable-off-grid"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "electric-switch"},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		max_health = 0,
		maximum_wire_distance = 5,
		supply_area_distance = 1.5,
		pictures =
		{
			filename = "__electric-switch__/graphics/switch.png",
			priority = "high",
			width = 0,--123,
			height = 0,--124,
			axially_symetric = false,
			direction_count = 1,
			shift = {1.4, -1.1}
		},
		connection_points =
		{
			{
				shadow =
				{
					copper = {2.2 , 0},
					red =	{1.9,	0},
					green =	{2.5 , 0}
				},
				wire =
				{
					copper = {0.05 , -2.04},
					red =	{-0.25, -2.04},
					green =	{0.35 , -2.04}
				}
			},
		},
		copper_wire_picture = wire_pictures.copper,
		green_wire_picture = wire_pictures.green,
		radius_visualisation_picture = wire_pictures.radius,
		red_wire_picture = wire_pictures.red,
		wire_shadow_picture = wire_pictures.shadow,
	},

	{
		type = "electric-pole",
		name = "south-node",
		icon = "__electric-switch__/graphics/switch-icon.png",
		flags = {"placeable-off-grid"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "electric-switch"},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		max_health = 0,
		maximum_wire_distance = 5,
		supply_area_distance = 1.5,
		pictures =
		{
			filename = "__electric-switch__/graphics/switch.png",
			priority = "high",
			width = 0,--123,
			height = 0,--124,
			axially_symetric = false,
			direction_count = 1,
			shift = {1.4, -1.1}
		},
		connection_points =
		{
			{
				shadow =
				{
					copper = {2.2 , 0},
					red =	{1.9,	0},
					green =	{2.5 , 0}
				},
				wire =
				{
					copper = {0.05 , -2.05},
					red =	{-0.25, -2.05},
					green =	{0.35 , -2.05}
				}
			},
		},
		copper_wire_picture = wire_pictures.copper,
		green_wire_picture = wire_pictures.green,
		radius_visualisation_picture = wire_pictures.radius,
		red_wire_picture = wire_pictures.red,
		wire_shadow_picture = wire_pictures.shadow,
	},
})

table.insert(data.raw["technology"]["electric-energy-distribution-1"].effects, { type = "unlock-recipe", recipe = "electric-switch"})
