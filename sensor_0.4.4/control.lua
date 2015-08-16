require "defines"

function prt(value) 
	game.players[1].print(tostring(value))
end

game.on_init(function()
	init()
end)

game.on_load(function()
	for _, force in ipairs(game.forces) do 
		force.reset_technologies() 
		if force.technologies["circuit-network"].researched then 
			force.recipes["directional-sensor"].enabled = true
		end
	end

	init()
	
	for _,sensor in ipairs(global.sensors) do
		if sensor.target ~= nil and sensor.target.valid then
			findFunction(sensor, sensor.target)
		end
	end
end)

function init()
	if global.sensors == nil then 
		global.sensors = {}
	else
		for _,sensor in ipairs(global.sensors) do
			insertAt(sensor.base.position, sensor)
			insertAt(sensor.output.position, sensor)
		end
	end
end

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

game.on_event(defines.events.on_tick, function(event)
	
	for i,sensor in ipairs(global.sensors) do
		if sensor.base.valid and sensor.output.valid then
			if sensor.tickskip == nil then
				sensor.output.get_inventory(1).clear()
				if sensor.target ~= nil and sensor.target.valid then
					if sensor.base.energy > 0 then
						sensor.tickFunction(sensor)
					end
				elseif sensor.tiles ~= nil then
					sensor.tickFunction(sensor)
				else
					sensor.target = nil
					sensor.tickFunction = nil
					findTarget(sensor)
				end
			else
				sensor.tickskip = sensor.tickskip - 1
				if sensor.tickskip <= 0 then
					sensor.tickskip = nil
				end
			end
		else
			global.sensors[i] = nil
		end
	end
	
	if game.tick % 60 == 0 then
		-- table cleanup (nil removal)
		local j=0
		local n = #global.sensors
		for i=1,n do
			if global.sensors[i]~=nil then
				j=j+1
				global.sensors[j]=global.sensors[i]
			end
		end
		for i=j+1,n do
			global.sensors[i]=nil
		end
	end
end)

function ticksensor_belt(sensor) 
	local left = sensor.target.get_transport_line(1).get_item_count() -- left
	local right = sensor.target.get_transport_line(2).get_item_count() -- right

	if left > 0 then sensor.output.insert{name = "belt-left", count = left} end
	if right > 0 then sensor.output.insert{name = "belt-right", count = right} end
end

function insert_inventory(sensor, index)
	local contentsTable = sensor.target.get_inventory(index).get_contents()
	for k,v in pairs(contentsTable) do
		sensor.output.insert{name = k, count = v}
	end
end

function insert_inventory_player(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	insert_inventory(sensor, 3)
	insert_inventory(sensor, 4)
	insert_inventory(sensor, 5)
	insert_inventory(sensor, 6)
end

function insert_inventory_car(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	insert_inventory(sensor, 3)
end

function insert_energy(sensor)
	local charge = math.ceil(sensor.target.energy / 1000)
	if charge > 0 then 
		sensor.output.insert{name = "energy-unit", count = charge}
	end
end

function checkStationary(sensor)
	if sensor.vehiclepos == nil then
		sensor.vehiclepos = {x = sensor.target.position.x, y = sensor.target.position.y}
	else
		if sensor.vehiclepos.x == sensor.target.position.x and sensor.vehiclepos.y == sensor.target.position.y then
			return true
		else
			sensor.target = nil
			sensor.vehiclepos = nil
			findTarget(sensor)
		end
	end
	return false
end

function ticksensor_container(sensor)
	insert_inventory(sensor, 1)
end

function ticksensor_cargowagon(sensor)
	sensor.output.insert{name = "detected-train", count = 1}
	if checkStationary(sensor) then
		insert_inventory(sensor, 1)
	end
end

function ticksensor_locomotive(sensor)
	sensor.output.insert{name = "detected-train", count = 1}
	if checkStationary(sensor) then
		insert_inventory(sensor, 1)
		insert_energy(sensor)
	end
end

function ticksensor_car(sensor)
	sensor.output.insert{name = "detected-car", count = 1}
	if checkStationary(sensor) then
		insert_inventory_car(sensor)
		insert_energy(sensor)
	end
end

function ticksensor_player(sensor)
	sensor.output.insert{name = "detected-player", count = 1}
	if checkStationary(sensor) then
		insert_inventory_player(sensor)
	end
end

function ticksensor_furnace(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	insert_inventory(sensor, 3)
	--insert_inventory(sensor, 4) --> ignore modules
	insert_energy(sensor)
end

function ticksensor_ammoturret(sensor)
	insert_inventory(sensor, 1)
end

function ticksensor_assembler(sensor)
	insert_inventory(sensor, 2)
	insert_inventory(sensor, 3)
	--insert_inventory(sensor, 4) --> ignore modules
	insert_energy(sensor)
end

function ticksensor_lab(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	--insert_inventory(sensor, 3) --> ignore modules
	insert_energy(sensor)
end

function ticksensor_roboport(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	insert_energy(sensor)
end

function ticksensor_micro_accumulator(sensor)
	if sensor.target.energy > 5000 then
		sensor.output.insert{name = "energy-unit", count = 1}
	end
end

function ticksensor_drill(sensor)
	sensor.tickskip = 20
	
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
			sensor.output.insert{name = k, count = v}
		else
			sensor.output.insert{name = "fluid-unit", count = v}
		end
	end
end

function ticksensor_fluidbox(sensor)
	local fbs = sensor.target.fluidbox
	for i = 1, #fbs do
		sensor.output.insert{name = "fluid-unit", count = math.ceil(fbs[1].amount - 0.5)}
		sensor.output.insert{name = "heat-unit", count = math.ceil(fbs[1].temperature - 0.5)}
	end
end

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

function findFunction(sensor, entity)

	local func = searchHandler[entity.type]
	if func ~= nil then
		sensor.tickFunction = func
		return true
	elseif entity.energy ~= nil then
		if entity.name == "micro-accumulator" then
			sensor.tickFunction = ticksensor_micro_accumulator
		else
			sensor.tickFunction = insert_energy
		end 
		return true
	elseif entity.fluidbox ~= nil and #entity.fluidbox > 0 then
		sensor.tickFunction = ticksensor_fluidbox
		return true
	end
		
end

function findTarget(sensor)
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
	
	return false 
end

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

function ticksensor_pressurefloor(sensor)
	if sensor.tilewait == nil then
		if sensor.base.energy > 0 then
			local targets = sensor.base.surface.find_entities(sensor.tiles)
			for _,entity in ipairs(targets) do
				local detected = pressurefloorHandler[entity.type]
				if detected ~= nil then
					sensor.output.insert{name = detected, count = 1}
					local inventory_insert_func = pressurefloorInventoriesHandler[entity.type]
					if inventory_insert_func ~= nil then
						sensor.target = entity
						inventory_insert_func(sensor)
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

local tilelimit_length = 25
local tilelimit_side = 24
function findfloor(sensor, surface, collectedTiles)
	local startX = sensor.targetX
	local startY = sensor.targetY
	local dir = sensor.base.direction
	
	findtilestrip(dir, startX, startY, tilelimit_length, surface, collectedTiles)
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
	
	local numLeft = tilelimit_side
	local numRight = tilelimit_side
	for i = 1, tilelimit_side do
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
	for i = 1, tilelimit_side do
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
		
		local output = entity.surface.create_entity{name = "directional-sensor-output", position = {posX_A, posY_A}, force = entity.force}
		output.destructible = false
		output.operable = false
		
		local sensor = {base = entity, output = output, targetX = posX_B, targetY = posY_B}
		table.insert(global.sensors, sensor)
		
		insertAt(entity.position, sensor)
		insertAt(sensor.output.position, sensor)
	end
end

function removeBase(sensor)
	sensor.output.destroy()
end

function removeOutput(sensor)
	sensor.output.get_inventory(1).clear()
	sensor.base.destroy()
end

removeHandler = {
	["directional-sensor"] = removeBase,
	["directional-sensor-output"] = removeOutput,
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

game.on_event(defines.events.on_built_entity, function(event)
	createSensor(event.created_entity)
end)

game.on_event(defines.events.on_robot_built_entity, function(event)
	createSensor(event.created_entity)
end)

game.on_event(defines.events.on_player_rotated_entity, function(event)
	if event.entity.name == "directional-sensor" then
		event.entity.direction = (event.entity.direction + 4) % 8 -- basically a fuck you to any rotation request
	end
end)

game.on_event(defines.events.on_preplayer_mined_item, function(event)
	removeSensor(event.entity)
end)

game.on_event(defines.events.on_robot_pre_mined, function(event)
	removeSensor(event.entity)
end)