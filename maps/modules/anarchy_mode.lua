-- Anarchy mode - by mewmew
-- all players have their own force
-- create a tag group to form alliances
-- empty groups will be deleted

local event = require 'utils.event'
local message_color = {r=0.8, g=0.3, b=0.45}

local function anarchy_gui_button(player)
	if not player.gui.top["anarchy_group_button"] then
		local b = player.gui.top.add({type = "button", name = "anarchy_group_button", caption = global.player_group[player.name], tooltip = "Join / Create a group"})
		b.style.font_color = {r = 0.77, g = 0.77, b = 0.77}
		b.style.font = "default-bold"
		b.style.minimal_height = 38
		b.style.minimal_width = 38
		b.style.top_padding = 2
		b.style.left_padding = 4
		b.style.right_padding = 4
		b.style.bottom_padding = 2
	end
end

local function anarchy_gui(player)
	local group_name_width = 160
	local description_width = 200
	local members_width = 120
	local member_columns = 3
	local actions_width = 60
	local total_height = 350	

	if player.gui.left["anarchy_group_frame"] then player.gui.left["anarchy_group_frame"].destroy() end
	
	local frame = player.gui.left.add({type = "frame", name = "anarchy_group_frame", direction = "vertical"})
	frame.style.minimal_height = total_height
	
	local t = frame.add({type = "table", column_count = 5})
	local headings = {{"Title", group_name_width}, {"Description", description_width}, {"Members", members_width * member_columns}, {"", actions_width*2 - 30}}
	for _, h in pairs (headings) do			
		local l = t.add({ type = "label", caption = h[1]})
		l.style.font_color = { r=0.98, g=0.66, b=0.22}
		l.style.font = "default-listbox"
		l.style.top_padding = 6
		l.style.minimal_height = 40
		l.style.minimal_width = h[2]
		l.style.maximal_width = h[2]
	end
	local b = t.add {type = "button", caption = "X", name = "close_alliance_group_frame", align = "right"}	
	b.style.font = "default"
	b.style.minimal_height = 30
	b.style.minimal_width = 30
	b.style.top_padding = 2
	b.style.left_padding = 4
	b.style.right_padding = 4
	b.style.bottom_padding = 2
	
	local scroll_pane = frame.add({ type = "scroll-pane", name = "scroll_pane", direction = "vertical", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto"})
	scroll_pane.style.maximal_height = total_height - 50
	scroll_pane.style.minimal_height = total_height - 50
	
	local t = scroll_pane.add({type = "table", name = "groups_table", column_count = 4})
	for _, h in pairs (headings) do	
		local l = t.add({ type = "label", caption = ""})
		l.style.minimal_width = h[2]
		l.style.maximal_width = h[2]
	end	

	for _, group in pairs (global.alliance_groups) do
		
		local l = t.add({ type = "label", caption = group.name})
		l.style.font = "default-bold"
		l.style.top_padding = 16
		l.style.bottom_padding = 16
		l.style.minimal_width = group_name_width
		l.style.maximal_width = group_name_width
		l.style.font_color = group.color
		l.style.single_line = false
		
		local l = t.add({ type = "label", caption = group.description})
		l.style.top_padding = 16
		l.style.bottom_padding = 16
		l.style.minimal_width = description_width
		l.style.maximal_width = description_width
		l.style.font_color = {r = 0.90, g = 0.90, b = 0.90}		
		l.style.single_line = false
		
		local tt = t.add({ type = "table", column_count = member_columns})
		for _, member in pairs (group.members) do
			local p = game.players[member]	
			if p.connected then
				local l = tt.add({ type = "label", caption = p.name})
				local color = {r = p.color.r * 0.6 + 0.4, g = p.color.g * 0.6 + 0.4, b = p.color.b * 0.6 + 0.4, a = 1}			
				l.style.font_color = color
				l.style.maximal_width = members_width * 2	
			end			
		end
		
		for _, member in pairs (group.members) do
			local p = game.players[member]	
			if not p.connected then
				local l = tt.add({ type = "label", caption = p.name})
				local color = {r = 0.59, g = 0.59, b = 0.59, a = 1}			
				l.style.font_color = color			
				l.style.maximal_width = members_width * 2
			end
		end		
		
		local tt = t.add({ type = "table", name = group.name, column_count = 1})	
		
		if not group.members[player.name] then
			local b = tt.add({ type = "button", caption = "Join"})
			b.style.font = "default-bold"
			b.style.minimal_width = actions_width
			b.style.maximal_width = actions_width
		end
		
		if group.members[player.name] then			
			local b = tt.add({ type = "button", caption = "Leave"})
			b.style.font = "default-bold"
			b.style.minimal_width = actions_width
			b.style.maximal_width = actions_width
		end
	end		
	
	local frame2 = frame.add({type = "frame", name = "frame2"})
	local t = frame2.add({type = "table", name = "group_table", column_count = 3})
	local textfield = t.add({ type = "textfield", name = "new_group_name", text = "Name" })
	textfield.style.minimal_width = group_name_width
	local textfield = t.add({ type = "textfield", name = "new_group_description", text = "Description" })
	textfield.style.minimal_width = description_width + members_width * member_columns
	local b = t.add({type = "button", name = "create_new_group", caption = "Create"})
	b.style.minimal_width = actions_width*2 - 12
	b.style.font = "default-bold"
		
end

local function refresh_gui()
	for _, p in pairs(game.connected_players) do
		if p.gui.left["anarchy_group_frame"] then
		
			local frame = p.gui.left["anarchy_group_frame"]
			local new_group_name = frame.frame2.group_table.new_group_name.text
			local new_group_description = frame.frame2.group_table.new_group_description.text
			
			anarchy_gui(p)
			
			local frame = p.gui.left["anarchy_group_frame"]
			frame.frame2.group_table.new_group_name.text = new_group_name
			frame.frame2.group_table.new_group_description.text = new_group_description
			
		end
	end
end

local function destroy_request_guis(player)
	for _, p in pairs(game.players) do
		if p.gui.center["alliance_request_" .. player.name] then p.gui.center["alliance_request_" .. player.name].destroy() end
	end
end

local function request_alliance(group, requesting_player)
	if not global.alliance_groups[group] then return end
	
	destroy_request_guis(requesting_player)
	
	for _, member in pairs(global.alliance_groups[group].members) do
		local player = game.players[member]				
		local frame = player.gui.center.add({type = "frame", caption = requesting_player.name .. ' wants to join your group "' .. group .. '"', name = "alliance_request_" .. requesting_player.name})
		frame.add({type = "label", caption = "", name = group})
		frame.add({type = "label", caption = "", name = requesting_player.index})
		frame.add({type = "button", caption = "Accept"})
		frame.add({type = "button", caption = "Deny"})
	end			
end

local function refresh_alliances()
	local players_to_process = {}
	for _, player in pairs(game.players) do
		players_to_process[player.index] = true
	end
	
	for _, group in pairs(global.alliance_groups) do
		local i = 0
		for _, member in pairs(group.members) do
			local player = game.players[member]
			players_to_process[player.index] = nil
			player.gui.top["anarchy_group_button"].caption = "[" .. group.name .. "]"
			player.tag = "[" .. group.name .. "]"
			player.force = game.forces[group.name]
			i = i + 1
		end
		if i == 0 then
			game.print('Group "' .. group.name .. '" has been abandoned!!', {r=0.90, g=0.0, b=0.0})
			global.alliance_groups[group.name] = nil			
		end
	end
	
	for _, player in pairs(game.players) do
		if players_to_process[player.index] then
			player.gui.top["anarchy_group_button"].caption = "[Group]"
			player.tag = ""			
			player.force = game.forces[player.name]
			players_to_process[player.index] = nil
		end
	end
	refresh_gui()
end

local function new_group(frame, player)								
	local new_group_name = frame.frame2.group_table.new_group_name.text
	local new_group_description = frame.frame2.group_table.new_group_description.text
	if new_group_name ~= "" and new_group_name ~= "Name" and new_group_description ~= "Description" then
		
		if player.tag ~= "" then
			player.print("You are already in a group.", {r=0.90, g=0.0, b=0.0})
			return
		end
		
		if string.len(new_group_name) > 32 then
			player.print("Group name is too long. 32 characters maximum.", {r=0.90, g=0.0, b=0.0})
			return
		end
		
		if string.len(new_group_description) > 128 then
			player.print("Description is too long. 128 characters maximum.", {r=0.90, g=0.0, b=0.0})				
			return
		end
		
		if global.alliance_groups[new_group_name] then
			player.print("This groupname already exists.", {r=0.90, g=0.0, b=0.0})				
			return
		end
		
		local color = player.color
		color = {r = color.r * 0.6 + 0.4, g = color.g * 0.6 + 0.4, b = color.b * 0.6 + 0.4, a = 1}
		
		global.alliance_groups[new_group_name] = {name = new_group_name, color = color, description = new_group_description, members = {[player.name] = player.index}}
		local color = {r = player.color.r * 0.7 + 0.3, g = player.color.g * 0.7 + 0.3, b = player.color.b * 0.7 + 0.3, a = 1}
		game.print(player.name .. " has founded a new group!", color)
		game.print('>> ' .. new_group_name, { r=0.98, g=0.66, b=0.22})
		game.print(new_group_description, { r=0.85, g=0.85, b=0.85})
		
		frame.frame2.group_table.new_group_name.text = "Name"
		frame.frame2.group_table.new_group_description.text = "Description"
		
		if not game.forces[new_group_name] then game.create_force(new_group_name) end
		
		refresh_alliances()		
		return
	end			
end

local function on_gui_click(event)
	if not event then return end
	if not event.element then return end
	if not event.element.valid then return end	
	local player = game.players[event.element.player_index]
	local name = event.element.name
	
	if event.element.caption == "Accept" then
		local frame = event.element.parent
		if not frame then return end
		local group = frame.children[1].name
		local requesting_player = game.players[tonumber(frame.children[2].name)]	
		
		if requesting_player.tag then
			if requesting_player.tag ~= "" then
				local requesting_player_group = string.sub(requesting_player.tag, 2, string.len(requesting_player.tag) - 1)	
				global.alliance_groups[requesting_player_group].members[requesting_player.name] = nil
			end
		end
		
		global.alliance_groups[group].members[requesting_player.name] = requesting_player.index		
		game.print(requesting_player.name .. ' has been accepted into group "' .. group .. '"', message_color)
				
		refresh_alliances()	
		
		destroy_request_guis(requesting_player)				
		return
	end
	
	if event.element.caption == "Deny" then
		local frame = event.element.parent
		if not frame then return end
		local group = frame.children[1].name
		local requesting_player = game.players[tonumber(frame.children[2].name)]
		
		game.print(requesting_player.name .. ' has been rejected to join group "' .. group .. '"', message_color)
		
		for _, member in pairs(global.alliance_groups[group].members) do
			local p = game.players[member]
			if p.gui.center["alliance_request_" .. requesting_player.name] then p.gui.center["alliance_request_" .. requesting_player.name].destroy() end
		end								
		return				
	end
	
	local frame = player.gui.left["anarchy_group_frame"]
	if name == "create_new_group" then new_group(frame, player) return end
	
	local p = event.element.parent
	if p then p = p.parent end
	if p then
		if p.name == "groups_table" then			
			if event.element.type == "button" and event.element.caption == "Join" then
				destroy_request_guis(player)			
				player.print("A request to join the group has been sent.", message_color) 
				request_alliance(event.element.parent.name, player)			
			end			

			if event.element.type == "button" and event.element.caption == "Leave" then
				destroy_request_guis(player)
				global.alliance_groups[event.element.parent.name].members[player.name] = nil
				game.print(player.name .. ' has left group "' .. event.element.parent.name .. '"', message_color)
				refresh_alliances()									
				return
			end			
		end
	end
	
	if name == "anarchy_group_button" then
		if frame then
			frame.destroy()
		else
			anarchy_gui(player)
		end
	end
	
	if name == "close_alliance_group_frame" then
		frame.destroy()
	end
end

local function on_player_joined_game(event)
	local player = game.players[event.player_index]
	if not global.alliance_groups then global.alliance_groups = {} end
	if not global.spam_protection then global.spam_protection = {} end	
	if not global.spam_protection[player.name] then global.spam_protection[player.name] = game.tick end		
	if not game.forces[player.name] then game.create_force(player.name) end
	
	if player.gui.left["group_frame"] then player.gui.left["group_frame"].destroy() end
	if player.gui.top["group_button"] then player.gui.top["group_button"].destroy() end	
	
	anarchy_gui_button(player)
	
	refresh_alliances()
end

event.add(defines.events.on_gui_click, on_gui_click)
event.add(defines.events.on_player_joined_game, on_player_joined_game)