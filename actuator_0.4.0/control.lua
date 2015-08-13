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
	if global.actuators == nil then 
		global.actuators = {}
	else
		for _,actuator in ipairs(global.actuators) do
			insertAt(actuator.base.position, actuator)
		end
	end
	if global.gateforce == nil then
		global.gateforce = game.create_force("gate")
	end
end

positions = {}

function insertAt(pos, reference)
	if positions[pos.x] == nil then positions[pos.x] = {} end
	if positions[pos.x][pos.y] == nil then positions[pos.x][pos.y] = {} end
	positions[pos.x][pos.y] = reference
end

function getAt(pos)
	if positions[pos.x] == nil then return nil end
	return positions[pos.x][pos.y]
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

game.on_event(defines.events.on_tick, function(event)
	
	for i,actuator in ipairs(global.actuators) do
		if actuator.base.valid then
			if actuator.target ~= nil and actuator.target.valid then
				if not actuator.checkForMovement or checkStationary(actuator) then
					local newState
					if actuator.base.energy > 0 then
						newState = testConditionFulfilled(actuator.base)
					else
						newState = false
					end
					
					if newState ~= actuator.state then
						actuator.state = newState
						setIndicator(actuator)
						actuator.tickFunction(actuator)
					elseif not actuator.behavesAsToggle and actuator.base.energy > 0 then
						actuator.tickFunction(actuator)
					end
				end
			else
				resetActuator(actuator)
			end
		else
			global.actuators[i] = nil
		end
	end
	
	if game.tick % 60 == 0 then
		table_nil_cleanup(global.actuators)
	end
end)

function testConditionFulfilled(wireConnectedObject)
	
	local wCondition = wireConnectedObject.get_circuit_condition(1)
	local lCondition = wireConnectedObject.get_circuit_condition(2)
	
	return lCondition.fulfilled or wCondition.fulfilled
end

function checkStationary(actuator)
	if actuator.vehiclepos == nil then
		actuator.vehiclepos = {x = actuator.target.position.x, y = actuator.target.position.y}
	else
		if actuator.vehiclepos.x == actuator.target.position.x and actuator.vehiclepos.y == actuator.target.position.y then
			return true
		else
			actuator.target = nil
			actuator.vehiclepos = nil
		end
	end
	return false
end

local magic_tick_limit = 8
function tickactuator_train(actuator)

	-- need some tricky waiting a few ticks or else inserters won't work on the train (no clue why, must be magic)

	if actuator.state then
		
		if actuator.waitT == nil then
			actuator.waitF = nil
			actuator.waitT = 0
		else
			if actuator.waitT < magic_tick_limit then
				actuator.waitT = actuator.waitT + 1
				if actuator.waitT == magic_tick_limit then
					actuator.target.train.manual_mode = actuator.state
				end
			end
		end
		
	else
		
		if actuator.waitF == nil then
			actuator.waitT = nil
			actuator.waitF = 0
		else
			if actuator.waitF < magic_tick_limit then
				actuator.waitF = actuator.waitF + 1
				if actuator.waitF == magic_tick_limit then
					actuator.target.train.manual_mode = actuator.state
				end
			end
		end
		
	end
	
	
end

function tickactuator_car(actuator)
	tickactuator_activation(actuator)
end

function tickactuator_gate(actuator)
	if actuator.state then
		actuator.target.request_to_open(global.gateforce)
	else
		actuator.target.request_to_close(global.gateforce)
	end
end

function resetActuator(actuator)
	actuator.target = nil
	actuator.tickFunction = nil
	actuator.state = testConditionFulfilled(actuator.base)
	actuator.checkForMovement = false
	actuator.behavesAsToggle = true
	actuator.waitT = nil
	actuator.waitF = nil
	restoreGateSegments(actuator)
	if actuator.base.energy > 0 then
		setIndicator(actuator)
	end
	if findTarget(actuator) then
		actuator.state = not actuator.state -- force a change, but only in the next tick
	end
end

function restoreGateSegments(actuator)
	if actuator.gateSegments ~= nil then
		for _,segment in ipairs(actuator.gateSegments) do
			if segment.valid then
				segment.force = actuator.base.force
			end
		end
	end
	actuator.gateSegments = nil
end

function findGateSegments(actuator)
	local surface = actuator.base.surface
	local x = actuator.targetX
	local y = actuator.targetY
	local name = actuator.target.name
	local dir = actuator.target.direction
	
	local segments = {actuator.target}
	if dir == 2 then
		-- horizontal
		for i = 1, 1000 do
			local adj = surface.find_entities_filtered{area = {{x - 0.1 + i, y - 0.1}, {x + 0.1 + i, y + 0.1}}, name = name}
			if #adj == 0 or not adj[1].valid or adj[1].direction ~= dir then
				break
			else
				table.insert(segments, adj[1])
			end
		end
		for i = 1, 1000 do
			local adj = surface.find_entities_filtered{area = {{x - 0.1 - i, y - 0.1}, {x + 0.1 - i, y + 0.1}}, name = name}
			if #adj == 0 or not adj[1].valid or adj[1].direction ~= dir then
				break
			else
				table.insert(segments, adj[1])
			end
		end
	else
		-- vertical
		for i = 1, 1000 do
			local adj = surface.find_entities_filtered{area = {{x - 0.1, y - 0.1 + i}, {x + 0.1, y + 0.1 + i}}, name = name}
			if #adj == 0 or not adj[1].valid or adj[1].direction ~= dir then
				break
			else
				table.insert(segments, adj[1])
			end
		end
		for i = 1, 1000 do
			local adj = surface.find_entities_filtered{area = {{x - 0.1, y - 0.1 - i}, {x + 0.1, y + 0.1 - i}}, name = name}
			if #adj == 0 or not adj[1].valid or adj[1].direction ~= dir then
				break
			else
				table.insert(segments, adj[1])
			end
		end
	end
	for _,segment in ipairs(segments) do
		segment.force = global.gateforce
	end
	actuator.gateSegments = segments
end

function tickactuator_flip(actuator)
	actuator.target.direction = (actuator.target.direction + 4) % 8
end

function tickactuator_activation(actuator)
	actuator.target.active = not actuator.state
end

searchHandler = {
	["locomotive"] = tickactuator_train,
	["transport-belt"] = tickactuator_flip,
	["splitter"] = tickactuator_flip,
	["car"] = tickactuator_car,
	["gate"] = tickactuator_gate,
}

ignoredHandler = {
	["car"] = true,
	["player"] = true,
}

function findTarget(actuator)
	
	local adj = actuator.base.surface.find_entities_filtered{area = {{actuator.targetX - 0.1, actuator.targetY - 0.1}, {actuator.targetX + 0.1, actuator.targetY + 0.1}}, force = actuator.base.force}
	for _,entity in ipairs(adj) do
	
		local func = searchHandler[entity.type]
		if func ~= nil then
			actuator.tickFunction = func
			actuator.target = entity		
			if func == tickactuator_train or func == tickactuator_car then
				actuator.checkForMovement = true
				actuator.behavesAsToggle = false
			elseif func == tickactuator_gate then
				actuator.behavesAsToggle = false
				findGateSegments(actuator)
			end
			return true
		elseif ignoredHandler[entity.type] == nil and entity.energy ~= nil then
			actuator.tickFunction = tickactuator_activation
			actuator.target = entity
			return true
		end
		
	end
	return false 
end

function getAdjPos(entity)
	local dir = entity.direction
	local posX = entity.position.x
	local posY = entity.position.y
	if dir == 6 then 
		posX = posX + 1
	elseif dir == 2 then 
		posX = posX - 1
	elseif dir == 0 then 
		posY = posY + 1
	elseif dir == 4 then 
		posY = posY - 1
	end
	return posX, posY
end

function createActuator(entity)
	if entity.name == "directional-actuator" then
		
		local targetX, targetY = getAdjPos(entity)
		
		local indicator = entity.surface.create_entity{name = "indicator-green", position = entity.position}
		
		local actuator = {base = entity, indicator = indicator, targetX = targetX, targetY = targetY, state = false, checkForMovement = false, behavesAsToggle = true}
		setIndicator(actuator)
		table.insert(global.actuators, actuator)
		
		insertAt(entity.position, actuator)
	end
end

game.on_event(defines.events.on_player_rotated_entity, function(event)
	if event.entity.name == "directional-actuator" then
		
		local targetX, targetY = getAdjPos(event.entity)
		
		local actuator = getAt(event.entity.position)
		tryDeactivate(actuator)
		
		actuator.targetX = targetX
		actuator.targetY = targetY
		resetActuator(actuator)
	end
end)

function tryDeactivate(actuator)
	if actuator.target ~= nil and actuator.target.valid and actuator.tickFunction ~= nil then
		actuator.state = false
		setIndicator(actuator)
		actuator.tickFunction(actuator)
	end
end

function setIndicator(actuator)
	if actuator.indicator ~= nil and actuator.indicator.valid then
		actuator.indicator.destroy()
	end
	
	if actuator.state then
		if actuator.target ~= nil and actuator.target.valid then
			actuator.indicator = actuator.base.surface.create_entity{name = "indicator-red", position = {x = actuator.base.position.x, y = actuator.base.position.y - 0.3}}
		else 
			actuator.indicator = actuator.base.surface.create_entity{name = "indicator-orange", position = {x = actuator.base.position.x, y = actuator.base.position.y - 0.3}}
		end
	else
		actuator.indicator = actuator.base.surface.create_entity{name = "indicator-green", position = {x = actuator.base.position.x, y = actuator.base.position.y - 0.3}}
	end
end

function removeActuator(entity)
	if entity.name == "directional-actuator" then
		local actuator = getAt(entity.position)
		tryDeactivate(actuator)
		restoreGateSegments(actuator)
		if actuator.indicator ~= nil and actuator.indicator.valid then
			actuator.indicator.destroy()
		end
	end
end

game.on_event(defines.events.on_built_entity, function(event)
	createActuator(event.created_entity)
end)

game.on_event(defines.events.on_robot_built_entity, function(event)
	createActuator(event.created_entity)
end)

game.on_event(defines.events.on_preplayer_mined_item, function(event)
	removeActuator(event.entity)
end)

game.on_event(defines.events.on_robot_pre_mined, function(event)
	removeActuator(event.entity)
end)
