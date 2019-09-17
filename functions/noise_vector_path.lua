--draws lines modified by noise -- mewmew

local simplex_noise = require "utils.simplex_noise".d2

function noise_vector_entity_path(surface, entity_name, position, base_vector, length, collision)
	local seed_1 = math.random(1, 10000000)
	local seed_2 = math.random(1, 10000000)
	local vector = {}
	local entities = {}
	local minimal_movement = 0.5

	for a = 1, length, 1 do
		if collision then
			if surface.can_place_entity({name = entity_name, position = position}) then
				entities[#entities + 1] = surface.create_entity({name = entity_name, position = position})
			end
		else
			entities[#entities + 1] = surface.create_entity({name = entity_name, position = position})
		end

		local noise = simplex_noise(position.x * 0.01, position.y * 0.01, seed_1)
		local noise_2 = simplex_noise(position.x * 0.01, position.y * 0.01, seed_2)

		vector[1] = base_vector[1] + noise * 0.85
		vector[2] = base_vector[2] + noise_2 * 0.85
		
		--enforce minimum movement
		if math.abs(vector[1]) < minimal_movement and math.abs(vector[2]) < minimal_movement then
			local i = math.random(1,2)
			if vector[i] < 0 then
				vector[i] = minimal_movement * -1
			else
				vector[i] = minimal_movement
			end
		end
		
		position = {x = position.x + vector[1], y = position.y + vector[2]}
	end
	
	return entities
end

function noise_vector_tile_path(surface, tile_name, position, base_vector, length)
	local seed_1 = math.random(1, 10000000)
	local seed_2 = math.random(1, 10000000)
	local vector = {}
	local minimal_movement = 0.5
	
	for a = 1, length, 1 do
		surface.set_tiles({{name = tile_name, position = position}}, true)
		local noise = simplex_noise(position.x * 0.1, position.y * 0.1, seed_1)
		local noise_2 = simplex_noise(position.x * 0.1, position.y * 0.1, seed_2)

		vector[1] = base_vector[1] + noise
		vector[2] = base_vector[2] + noise_2
			
		if math.abs(vector[1]) < minimal_movement and math.abs(vector[2]) < minimal_movement then
			local i = math.random(1,2)
			if vector[i] < 0 then
				vector[i] = minimal_movement * -1
			else
				vector[i] = minimal_movement
			end
		end	
		
		position = {x = position.x + vector[1], y = position.y + vector[2]}
	end
end

--/c noise_vector_path(game.player.surface, "tree-04", game.player.position, {0,0})