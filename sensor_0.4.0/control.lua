require "defines"

function prt(value) 
	game.players[1].print(tostring(value))
end

game.on_init(function()
	init()
end)

game.on_load(function()
	init()
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
		if sensor ~= nil then
			if sensor.base.valid and sensor.output.valid then
				sensor.output.get_inventory(1).clear()
				if sensor.target ~= nil and sensor.target.valid then
					if sensor.base.energy > 0 then
						sensor.tickFunction(sensor)
					end
				else
					sensor.target = nil
					sensor.tickFunction = nil
					findTarget(sensor)
				end
			else
				global.sensors[i] = nil
			end
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

function insert_energy(sensor)
	local charge = math.ceil((sensor.target.energy - 999.9) / 1000)
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
	if checkStationary(sensor) then
		insert_inventory(sensor, 1)
	else
		sensor.output.insert{name = "moving-train", count = 1}
	end
end

function ticksensor_locomotive(sensor)
	if checkStationary(sensor) then
		insert_inventory(sensor, 1)
		insert_energy(sensor)
	else
		sensor.output.insert{name = "moving-train", count = 1}
	end
end

function ticksensor_car(sensor)
	if checkStationary(sensor) then
		insert_inventory(sensor, 1)
		insert_inventory(sensor, 2)
		insert_inventory(sensor, 3)
		insert_energy(sensor)
	end
end

function ticksensor_furnace(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	insert_inventory(sensor, 3)
	--insert_inventory(sensor, 4) -> ignore modules
	insert_energy(sensor)
end

function ticksensor_ammoturret(sensor)
	insert_inventory(sensor, 1)
end

function ticksensor_assembler(sensor)
	insert_inventory(sensor, 2)
	insert_inventory(sensor, 3)
	--insert_inventory(sensor, 4) -> ignore modules
	insert_energy(sensor)
end

function ticksensor_lab(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	--insert_inventory(sensor, 3) -> ignore modules
	insert_energy(sensor)
end

function ticksensor_roboport(sensor)
	insert_inventory(sensor, 1)
	insert_inventory(sensor, 2)
	insert_energy(sensor)
end

searchHandler = {
	["container"] = ticksensor_container,
	["logistics-container"] = ticksensor_container,
	["smart-container"] = ticksensor_container,
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
}

function findTarget(sensor)
	
	local adj = sensor.base.surface.find_entities{{sensor.targetX - 0.1, sensor.targetY - 0.1}, {sensor.targetX + 0.1, sensor.targetY + 0.1}}
	for _,entity in ipairs(adj) do
	
		local func = searchHandler[entity.type]
		if func ~= nil then
			sensor.tickFunction = func
			sensor.target = entity	
			return true
		elseif entity.energy ~= nil then
			sensor.tickFunction = insert_energy
			sensor.target = entity	
			return true
		end
		
	end
	return false 
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

game.on_event(defines.events.on_preplayer_mined_item, function(event)
	removeSensor(event.entity)
end)

game.on_event(defines.events.on_robot_pre_mined, function(event)
	removeSensor(event.entity)
end)
