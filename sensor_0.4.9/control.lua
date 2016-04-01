require "defines"
require "config"

function prt(value) 
	game.players[1].print(tostring(value))
end

script.on_init(function()
	init()
end)

script.on_load(function()
	init()
	
	-- migration code for old functions
	for _,sensor in ipairs(global.sensors) do
		if sensor.target ~= nil and sensor.target.valid then
			findFunction(sensor, sensor.target)
		elseif sensor.tiles ~= nil then
			sensor.tickFunction = ticksensor_pressurefloor
		end
	end
end)

function init()
	if global.sensors == nil then 
		global.sensors = {}
	else
		for _,sensor in ipairs(global.sensors) do
			insertAt(sensor.base.position, sensor)
			if not sensor.output.valid then
				sensor.output = createOutput(sensor.base)
			end
			insertAt(sensor.output.position, sensor)
		end
	end
end

--------------------------
-- entity part tracking --

positions = {}

function insertAt(pos, reference)
	local x = math.ceil(pos.x)
	local y = math.ceil(pos.y)
	if positions[x] == nil then positions[x] = {} end
	if positions[x][y] == nil then positions[x][y] = {} end
	positions[x][y] = reference
end

function getAt(pos)
	local x = math.ceil(pos.x)
	local y = math.ceil(pos.y)
	if positions[x] == nil then return nil end
	return positions[x][y]
end

-----------------------------------
-- tick event (common functions) --

script.on_event(defines.events.on_tick, function(event)
	
	for i,sensor in ipairs(global.sensors) do
		if sensor.tickskip == nil then
			if sensor.base.valid and sensor.output.valid then
				
				if sensor.target ~= nil and sensor.target.valid then
					tick_once(sensor)
				elseif sensor.tiles ~= nil then
					tick_once(sensor)
				else
					if sensor.tickFunction ~= nil then
						tick_clear(sensor)
					end
					sensor.tickFunction = nil
					findTarget(sensor)
				end
				
				apply_tick_variation(sensor)
				
			else
				global.sensors[i] = nil
			end
		else
			-- delay 
			sensor.tickskip = sensor.tickskip - 1
			if sensor.tickskip <= 0 then
				sensor.tickskip = nil
			end
		end
	end
	
	if game.tick % 60 == 0 then
		table_nil_cleanup(global.sensors)
	end
end)

function apply_tick_variation(sensor)
	if SC_VARIATION and sensor.tickskip ~= nil then
		local semirandom 
		if sensor.base.valid and sensor.base.x ~= nil then
			semirandom = sensor.base.x * 4049 - sensor.base.y * 7039
		else
			semirandom = 4049
		end
		local variation_span = max(4, (sensor.tickskip / 10))
		sensor.tickskip = sensor.tickskip + (semirandom % variation_span) - (variation_span / 2)
	end
end

function table_nil_cleanup(targetTable)
	local j=0
	local n = #targetTable
	for i=1,n do
		if targetTable[i]~=nil then
			j=j+1
			targetTable[j]=targetTable[i]
		end
	end
	for i=j+1,n do
		targetTable[i]=nil
	end
end

function tick_once(sensor)
	if sensor.base.energy <= 0 then
		tick_clear(sensor)
		return
	end
	
	local detected_table = {items = {}, fluids = {}, signals = {}}
	sensor.tickFunction(sensor, detected_table)
	local t = {parameters = {}}
	local i = 1
	for k,v in pairs(detected_table.items) do
		t.parameters[i]={signal={type = "item", name = k}, count = v, index = i}
		i = i + 1
	end
	for k,v in pairs(detected_table.fluids) do
		t.parameters[i]={signal={type = "fluid", name = k}, count = v, index = i}
		i = i + 1
	end
	for k,v in pairs(detected_table.signals) do
		t.parameters[i]={signal={type = "virtual", name = k}, count = v, index = i}
		i = i + 1
	end
	sensor.output.set_circuit_condition(1, t)
end

function tick_clear(sensor)
	sensor.output.set_circuit_condition(1, {parameters = {}})
end
		
function add_detected_items(detected_table, itemName, itemCount)
	local existing = detected_table.items[itemName]
	if existing == nil then 
		detected_table.items[itemName] = itemCount 
	else
		detected_table.items[itemName] = existing + itemCount
	end
end

function add_detected_fluids(detected_table, fluidName, fluidCount)
	local existing = detected_table.fluids[fluidName]
	if existing == nil then 
		detected_table.fluids[fluidName] = fluidCount 
	else
		detected_table.fluids[fluidName] = existing + fluidCount
	end
end

function add_detected_signals(detected_table, signalName, signalCount)
	local existing = detected_table.signals[signalName]
	if existing == nil then 
		detected_table.signals[signalName] = signalCount 
	else
		detected_table.signals[signalName] = existing + signalCount
	end
end

------------------------------------------
-- tick event (type specific functions) --

function ticksensor_belt(sensor, detected_table) 
	sensor.tickskip = SC_BELT_TICKS

	local left = sensor.target.get_transport_line(1) -- left
	local right = sensor.target.get_transport_line(2) -- right

	if left.get_item_count() > 0 then 
		add_detected_signals(detected_table, "belt-left", left.get_item_count())
		local contents = left.get_contents()
		for k,v in pairs(contents) do
			add_detected_items(detected_table, k, v)
		end
	end
	if right.get_item_count() > 0 then 
		add_detected_signals(detected_table, "belt-right", right.get_item_count()) 
		local contents = right.get_contents()
		for k,v in pairs(contents) do
			add_detected_items(detected_table, k, v)
		end
	end
end

function insert_inventory(sensor, index, detected_table)
	local contentsTable = sensor.target.get_inventory(index).get_contents()
	for k,v in pairs(contentsTable) do
		add_detected_items(detected_table, k, v)
	end
end

function insert_inventory_player(sensor, detected_table)
	insert_inventory(sensor, 1, detected_table)
	insert_inventory(sensor, 2, detected_table)
	insert_inventory(sensor, 3, detected_table)
	insert_inventory(sensor, 4, detected_table)
	insert_inventory(sensor, 5, detected_table)
	insert_inventory(sensor, 6, detected_table)
end

function insert_inventory_car(sensor, detected_table)
	insert_inventory(sensor, 1, detected_table)
	insert_inventory(sensor, 2, detected_table)
	insert_inventory(sensor, 3, detected_table)
end

function insert_energy(sensor, detected_table)
	local charge = math.ceil(sensor.target.energy / 1000)
	if charge > 0 then 
		add_detected_signals(detected_table, "energy-unit", charge)
	end
end

function insert_railtanker(sensor, detected_table)
	if remote.interfaces.railtanker and remote.interfaces.railtanker.getLiquidByWagon then
		local tankerval = remote.call("railtanker", "getLiquidByWagon", sensor.target)
		if tankerval ~= nil and tankerval.amount ~= nil then
			local amount = math.ceil(tankerval.amount)
			if amount > 0 then
				add_detected_fluids(detected_table, tankerval.type, amount)
			end
		end
	end
end

function checkStationary(sensor, detectedSpeed)
	if sensor.lastDetectedSpeed == nil then
		sensor.lastDetectedSpeed = detectedSpeed
	else
		if sensor.lastDetectedSpeed == detectedSpeed and detectedSpeed == 0 then
			return true
		else
			sensor.lastDetectedSpeed = nil
			findTarget(sensor)
		end
	end
	return false
end

function ticksensor_container(sensor, detected_table)
	sensor.tickskip = SC_CHEST_TICKS
	
	insert_inventory(sensor, 1, detected_table)
end

function ticksensor_cargowagon(sensor, detected_table)
	sensor.tickskip = SC_TRAIN_TICKS

	add_detected_signals(detected_table, "detected-train", 1)
	if checkStationary(sensor, sensor.target.train.speed) then
		insert_inventory(sensor, 1, detected_table)
		insert_railtanker(sensor, detected_table)
	end
end

function ticksensor_locomotive(sensor, detected_table)
	sensor.tickskip = SC_TRAIN_TICKS

	add_detected_signals(detected_table, "detected-train", 1)
	if checkStationary(sensor, sensor.target.train.speed) then
		insert_inventory(sensor, 1, detected_table)
		insert_energy(sensor, detected_table)
	end
end

function ticksensor_car(sensor, detected_table)
	sensor.tickskip = SC_CAR_TICKS

	add_detected_signals(detected_table, "detected-car", 1)
	if checkStationary(sensor, sensor.target.speed) then
		insert_inventory_car(sensor, detected_table)
		insert_energy(sensor, detected_table)
	end
end

function ticksensor_player(sensor, detected_table)
	sensor.tickskip = SC_PLAYER_TICKS
	
	add_detected_signals(detected_table, "detected-player", 1)
	if checkStationary(sensor, 0) then
		insert_inventory_player(sensor, detected_table)
	end
end

function ticksensor_furnace(sensor, detected_table)
	sensor.tickskip = SC_FURNACE_TICKS
	
	insert_inventory(sensor, 1, detected_table)
	insert_inventory(sensor, 2, detected_table)
	insert_inventory(sensor, 3, detected_table)
	--insert_inventory(sensor, 4, detected_table) --> ignore modules
	insert_energy(sensor, detected_table)
end

function ticksensor_ammoturret(sensor, detected_table)
	sensor.tickskip = SC_TURRET_TICKS
	
	insert_inventory(sensor, 1, detected_table)
end

function ticksensor_assembler(sensor, detected_table)
	sensor.tickskip = SC_ASSEMBLER_TICKS
	
	insert_inventory(sensor, 2, detected_table)
	insert_inventory(sensor, 3, detected_table)
	--insert_inventory(sensor, 4, detected_table) --> ignore modules
	insert_energy(sensor, detected_table)
end

function ticksensor_lab(sensor, detected_table)
	sensor.tickskip = SC_LAB_TICKS
	
	insert_inventory(sensor, 1, detected_table)
	insert_inventory(sensor, 2, detected_table)
	--insert_inventory(sensor, 3, detected_table) --> ignore modules
	insert_energy(sensor, detected_table)
end

function ticksensor_roboport(sensor, detected_table)
	sensor.tickskip = SC_ROBOPORT_TICKS
	
	if sensor.network == nil or not sensor.network.valid then
		sensor.network = sensor.base.force.find_logistic_network_by_position(sensor.target.position, sensor.base.surface)
	end
	if sensor.network ~= nil then
		add_detected_signals(detected_table, "home-lrobots", sensor.network.available_logistic_robots)
		add_detected_signals(detected_table, "home-crobots", sensor.network.available_construction_robots)
		add_detected_signals(detected_table, "all-lrobots", sensor.network.all_logistic_robots)
		add_detected_signals(detected_table, "all-crobots", sensor.network.all_construction_robots)
	end
	insert_inventory(sensor, 1, detected_table)
	insert_inventory(sensor, 2, detected_table)
	insert_energy(sensor, detected_table)
end

function ticksensor_energy_unit(sensor, detected_table)
	sensor.tickskip = SC_ENERGY_UNIT_TICKS
	insert_energy(sensor, detected_table)
end

function ticksensor_micro_accumulator(sensor, detected_table)
	if sensor.target.energy > 5000 then
		add_detected_signals(detected_table, "energy-unit", 1)
	end
end

function ticksensor_drill(sensor, detected_table)
	sensor.tickskip = SC_DRILL_TICKS
	
	local pos = sensor.target.position
	local radius = sensor.base.force.technologies["data-dummy-" .. sensor.target.name].research_unit_energy / 60
	sensor.drillarea = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}

	local totals = {}
	local resources = sensor.base.surface.find_entities_filtered{area = sensor.drillarea, type = "resource"}
	for _,resource in ipairs(resources) do
		if totals[resource.name] == nil then
			totals[resource.name] = resource.amount
		else
			totals[resource.name] = totals[resource.name] + resource.amount
		end
	end
	for k,v in pairs(totals) do
		if game.item_prototypes[k] ~= nil then
			add_detected_items(detected_table, k, v)
		elseif game.fluid_prototypes[k] ~= nil then
			add_detected_fluids(detected_table, k, v)
		end
	end
end

function ticksensor_fluidbox(sensor, detected_table)
	sensor.tickskip = SC_PIPES_TICKS
	
	local fbs = sensor.target.fluidbox
	for i = 1, #fbs do
		if fbs[i] ~= nil then
			local amount = math.ceil(fbs[i].amount - 0.5)
			local temperature = math.ceil(fbs[i].temperature - 0.5)
			if amount > 0 then 
				add_detected_fluids(detected_table, fbs[i].type, amount)
			end
			if temperature > 0 then 
				add_detected_signals(detected_table, "heat-unit", temperature)
			end
		end
	end
end

-------------------------------------------
-- entity type -> tick function mappings --

searchHandler = {
	["container"] = ticksensor_container,
	["logistics-container"] = ticksensor_container,
	["smart-container"] = ticksensor_container,
	["player"] = ticksensor_player,
	["cargo-wagon"] = ticksensor_cargowagon,
	["locomotive"] = ticksensor_locomotive,
	["car"] = ticksensor_car,
	["transport-belt"] = ticksensor_belt,
	["transport-belt-to-ground"] = ticksensor_belt,
	["furnace"] = ticksensor_furnace,
	["assembling-machine"] = ticksensor_assembler,
	["lab"] = ticksensor_lab,
	["roboport"] = ticksensor_roboport,
	["ammo-turret"] = ticksensor_ammoturret,
	["mining-drill"] = ticksensor_drill,
}

ignoredHandler = {
	["rail-tanker-proxy-noconnect"] = true,
	["rail-tanker-proxy"] = true,
}

function findFunction(sensor, entity)

	local func = searchHandler[entity.type]
	if func ~= nil then
		sensor.tickFunction = func
		return true
	elseif entity.energy ~= nil then
		if entity.name == "micro-accumulator" then
			sensor.tickFunction = ticksensor_micro_accumulator
		else
			sensor.tickFunction = ticksensor_energy_unit
		end 
		return true
	elseif entity.fluidbox ~= nil and #entity.fluidbox > 0 then
		-- Ignored fluidbox entities.
		if ignoredHandler[entity.name] == nil then
			sensor.tickFunction = ticksensor_fluidbox
			return true
		end
	end
		
end

function findTarget(sensor)
	sensor.target = nil
	local surface = sensor.base.surface
	
	local adj = surface.find_entities{{sensor.targetX - 0.1, sensor.targetY - 0.1}, {sensor.targetX + 0.1, sensor.targetY + 0.1}}
	for _,entity in ipairs(adj) do
		if findFunction(sensor, entity) then
			sensor.target = entity
			return true
		end
	end
	
	local tile = surface.get_tile(sensor.targetX, sensor.targetY)
	if tile.name == "pressure-floor" then
		local collectedTiles = {}
		sensor.tiles = findfloor(sensor, surface, collectedTiles)
		sensor.base.surface.set_tiles(collectedTiles)
		sensor.tilewait = 0
		sensor.tickFunction = ticksensor_pressurefloor
		return true
	end
	
	-- put at the end because I don't want this to trigger if a target was actually found
	sensor.tickskip = SC_SEARCH_TICKS
	return false 
end

---------------------------------------
-- pressure floor specific functions --

pressurefloorHandler = {
	["locomotive"] = "detected-train",
	["cargo-wagon"] = "detected-train",
	["car"] = "detected-car",
	["player"] = "detected-player",
	["unit"] = "detected-alien",
}

pressurefloorInventoriesHandler = {
	["car"] = insert_inventory_car,
	["player"] = insert_inventory_player,
	["locomotive"] = ticksensor_container,
	["cargo-wagon"] = ticksensor_container,
}

function ticksensor_pressurefloor(sensor, detected_table)
	if sensor.tilewait == nil then
		sensor.tickskip = SC_PRESSUREFLOOR_TICKS
		if sensor.base.energy > 0 then
			local targets = sensor.base.surface.find_entities(sensor.tiles)
			for _,entity in ipairs(targets) do
				local detected = pressurefloorHandler[entity.type]
				if detected ~= nil then
					add_detected_signals(detected_table, detected, 1)
					local inventory_insert_func = pressurefloorInventoriesHandler[entity.type]
					if inventory_insert_func ~= nil then
						sensor.target = entity
						inventory_insert_func(sensor, detected_table)
						sensor.target = nil
					end
				end
			end
		end
	else
		sensor.tilewait = sensor.tilewait + 1
		if sensor.tilewait > 15 then
			sensor.tilewait = nil
			local collectedTiles = {}
			findfloor(sensor, sensor.base.surface, collectedTiles)
			for _,tile in ipairs(collectedTiles) do
				tile.name = "pressure-floor"
			end
			sensor.base.surface.set_tiles(collectedTiles)
		end
	end
end

function findfloor(sensor, surface, collectedTiles)
	local startX = sensor.targetX
	local startY = sensor.targetY
	local dir = sensor.base.direction
	
	findtilestrip(dir, startX, startY, PRESSUREFLOOR_TILELIMIT_LENGTH, surface, collectedTiles)
	findtilestrip_sides(dir, startX, startY, surface, collectedTiles)
	
	local minX = startX
	local maxX = startX
	local minY = startY
	local maxY = startY
	for _,tile in ipairs(collectedTiles) do
		if minX > tile.position[1] then minX = tile.position[1] end
		if minY > tile.position[2] then minY = tile.position[2] end
		if maxX < tile.position[1] then maxX = tile.position[1] end
		if maxY < tile.position[2] then maxY = tile.position[2] end
	end
	return {{minX, minY}, {maxX, maxY}}
end

function findtilestrip_sides(dir, startX, startY, surface, collectedTiles)
	local offsetX = 0
	local offsetY = 0
	if dir == 6 then offsetY = -1
	elseif dir == 2 then offsetY = 1
	elseif dir == 0 then offsetX = 1
	elseif dir == 4 then offsetX = -1
	end
	
	local numForward = #collectedTiles
	local moreTiles = {}
	
	local numLeft = PRESSUREFLOOR_TILELIMIT_SIDE
	local numRight = PRESSUREFLOOR_TILELIMIT_SIDE
	for i = 1, PRESSUREFLOOR_TILELIMIT_SIDE do
		findtilestrip(dir, startX + i * offsetX, startY + i * offsetY, numForward, surface, moreTiles)
		if #moreTiles ~= numForward then
			numLeft = i - 1
			moreTiles = {}
			break
		else
			collectedTiles = TableConcat(collectedTiles, moreTiles)
			moreTiles = {}
		end
	end
	for i = 1, PRESSUREFLOOR_TILELIMIT_SIDE do
		findtilestrip(dir, startX - i * offsetX, startY - i * offsetY, numForward, surface, moreTiles)
		if #moreTiles ~= numForward then
			numRight = i - 1
			moreTiles = {}
			break
		else
			collectedTiles = TableConcat(collectedTiles, moreTiles)
			moreTiles = {}
		end
	end
	return numLeft, numRight
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function findtilestrip(dir, startX, startY, maxForward, surface, collectedTiles)
	local offsetX = 0
	local offsetY = 0
	if dir == 6 then offsetX = 1
	elseif dir == 2 then offsetX = -1
	elseif dir == 0 then offsetY = 1
	elseif dir == 4 then offsetY = -1
	end
	
	for i = 0, maxForward - 1 do
		if not findsingletile(startX + i * offsetX, startY + i * offsetY, surface, collectedTiles) then
			break
		end
	end
end

function findsingletile(x, y, surface, collectedTiles)
	local tile = surface.get_tile(x, y)
	if tile.name == "pressure-floor" or tile.name == "active-pressure-floor" then 
		local info = {name = "active-pressure-floor", position = {x, y}}
		table.insert(collectedTiles, info)
		return true
	else
		return false
	end
end

------------------------------
-- creation and destruction --

function getAdjPos(entity)
	local dir = entity.direction
	local posX_A = entity.position.x
	local posY_A = entity.position.y
	local posX_B = entity.position.x
	local posY_B = entity.position.y
	if dir == 6 then 
		posX_A = posX_A - 0.5
		posX_B = posX_B + 1.5
	elseif dir == 2 then 
		posX_A = posX_A + 0.5
		posX_B = posX_B - 1.5
	elseif dir == 0 then 
		posY_A = posY_A - 0.5
		posY_B = posY_B + 1.5
	elseif dir == 4 then 
		posY_A = posY_A + 0.5
		posY_B = posY_B - 1.5
	end
	return posX_A, posY_A, posX_B, posY_B
end

function createSensor(entity)
	if entity.name == "directional-sensor" then
		entity.operable = false
		
		local posX_A, posY_A, posX_B, posY_B = getAdjPos(entity)
		
		local sensor = {base = entity, output = createOutput(entity), targetX = posX_B, targetY = posY_B}
		table.insert(global.sensors, sensor)
		
		insertAt(sensor.base.position, sensor)
		insertAt(sensor.output.position, sensor)
	end
end

function createOutput(entity)
	local posX_A, posY_A, posX_B, posY_B = getAdjPos(entity)
	
	local output = entity.surface.create_entity{name = "sensor-output", position = {posX_A, posY_A}, force = entity.force}
	output.destructible = false
	output.operable = false
		
	return output
end

function removeBase(sensor)
	sensor.output.destroy()
end

function removeOutput(sensor)
	sensor.base.destroy()
end

removeHandler = {
	["directional-sensor"] = removeBase,
	["sensor-output"] = removeOutput,
}

function removeSensor(entity)
	if entity.valid then
		local func = removeHandler[entity.name]
		if func ~= nil then 
			local switch = getAt(entity.position)
			if switch ~= nil then func(switch) end
		end
	end
end 

script.on_event(defines.events.on_built_entity, function(event)
	createSensor(event.created_entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	createSensor(event.created_entity)
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
	if event.entity.name == "directional-sensor" then
		event.entity.direction = (event.entity.direction + 4) % 8 -- basically a fuck you to any rotation request
	end
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	removeSensor(event.entity)
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	removeSensor(event.entity)
end)
