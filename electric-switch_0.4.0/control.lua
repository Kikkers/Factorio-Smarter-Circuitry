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
	if global.switches == nil then 
		global.switches = {}
	else
		for _,switch in ipairs(global.switches) do
			insertAt(switch.base.position, switch)
			insertAt(switch.terminalA.position, switch)
			insertAt(switch.terminalB.position, switch)
		end
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

game.on_event(defines.events.on_tick, function(event)
	
	for i,switch in ipairs(global.switches) do
		if switch ~= nil then
			if switch.base.valid and switch.terminalA.valid and switch.terminalB.valid then
				tickSwitch(switch)
			else
				global.switches[i] = nil
			end
		end
	end
	
	if game.tick % 60 == 0 then
		-- table cleanup (nil removal)
		local j=0
		local n = #global.switches
		for i=1,n do
			if global.switches[i]~=nil then
				j=j+1
				global.switches[j]=global.switches[i]
			end
		end
		for i=j+1,n do
			global.switches[i]=nil
		end
	end
end)

function tickSwitch(switch)

	local isConditionFulfilled = testConditionFulfilled(switch.base)
	
	-- modify if changed
	if isConditionFulfilled ~= switch.activated then
		switch.activated = isConditionFulfilled
		if switch.activated then
			-- connect
			switch.terminalA.connect_neighbour(switch.terminalB)
		else
			-- disconnect all from terminalA
			local prevConnected = switch.terminalA.neighbours.copper
			
			switch.terminalA.disconnect_neighbour()
			
			-- reconnect all except terminalB
			for _,other in pairs(prevConnected) do
				if other.position.x ~= switch.terminalB.position.x or other.position.y ~= switch.terminalB.position.y then
					switch.terminalA.connect_neighbour(other)
				end
			end
		end
	end
end

function testConditionFulfilled(wireConnectedObject)
	
	local wCondition = wireConnectedObject.get_circuit_condition(1)
	local lCondition = wireConnectedObject.get_circuit_condition(2)
	
	return lCondition.fulfilled or wCondition.fulfilled
end

function createSwitch(entity)
	if entity.name == "electric-switch" then
		local isVertical = entity.direction % 4 == 0
		local pos = entity.position
		local fce = entity.force
		
		local sur = entity.surface
		
		local deco
		local terminalA
		local terminalB
		if isVertical then
			deco = sur.create_entity{name = "switch-deco-vertical", position = pos, force = fce}
			terminalA = sur.create_entity{name = "south-node", position = {x = pos.x, y = pos.y + 1}, force = fce}
			terminalB = sur.create_entity{name = "north-node", position = {x = pos.x, y = pos.y - 1}, force = fce}
		else
			deco = sur.create_entity{name = "switch-deco-horizontal", position = pos, force = fce}
			terminalA = sur.create_entity{name = "east-node", position = {x = pos.x + 1, y = pos.y}, force = fce}
			terminalB = sur.create_entity{name = "west-node", position = {x = pos.x - 1, y = pos.y}, force = fce}
		end
		-- start out disconnected
		terminalA.disconnect_neighbour()
		terminalB.disconnect_neighbour()
		terminalA.destructible = false
		terminalB.destructible = false
		
		local switch = {base = entity, terminalA = terminalA, terminalB = terminalB, deco = deco, activated = false}
		
		table.insert(global.switches, switch)
		insertAt(entity.position, switch)
		insertAt(terminalA.position, switch)
		insertAt(terminalB.position, switch)
	end
end

function removeBase(switch)
	switch.deco.destroy()
	switch.terminalA.destroy()
	switch.terminalB.destroy()
end

function removeA(switch)
	switch.base.destroy()
	switch.deco.destroy()
	switch.terminalB.destroy()

end

function removeB(switch)
	switch.base.destroy()
	switch.deco.destroy()
	switch.terminalA.destroy()
end

removeHandler = {
	["electric-switch"] = removeBase,
	["south-node"] = removeA,
	["north-node"] = removeB,
	["east-node"] = removeA,
	["west-node"] = removeB,
}

function removeSwitch(entity)
	if entity.valid then
		local func = removeHandler[entity.name]
		if func ~= nil then 
			local switch = getAt(entity.position)
			if switch ~= nil then func(switch) end
		end
	end
end 

game.on_event(defines.events.on_built_entity, function(event)
	createSwitch(event.created_entity)
end)

game.on_event(defines.events.on_robot_built_entity, function(event)
	createSwitch(event.created_entity)
end)

game.on_event(defines.events.on_player_rotated_entity, function(event)
	if event.entity.name == "electric-switch" then
		event.entity.direction = (event.entity.direction + 6) % 8 -- basically a fuck you to any rotation request
	end
end)

game.on_event(defines.events.on_preplayer_mined_item, function(event)
	removeSwitch(event.entity)
end)

game.on_event(defines.events.on_robot_pre_mined, function(event)
	removeSwitch(event.entity)
end)
