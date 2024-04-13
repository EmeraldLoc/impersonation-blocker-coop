-- name: Impersonation Blocker
-- description: Attempts to block innocent players from being impersonated

local previousNames = {}
local currentNames = {}

function on_recieve(p)
	djui_chat_message_create(tostring(p.message))
end

function strip_hex(name)
	-- create variables
	local s = ''
	local inSlash = false
	-- loop thru each character in the string
	for i = 1, #name do
		local c = name:sub(i,i)
		if c == '\\' then
			inSlash = not inSlash
		elseif not inSlash then
			s = s .. c
		end
	end
	s = s:gsub("\\", "")
	return s
end

function update()

	if not network_is_server() then return end

	for i = 0, MAX_PLAYERS - 1 do
		if gNetworkPlayers[i].connected then
			currentNames[i] = network_get_player_text_color_string(i) .. gNetworkPlayers[i].name

			if previousNames[i] ~= nil then
				if strip_hex(currentNames[i]) ~= strip_hex(previousNames[i]) and previousNames[i] ~= "" then
					for n = 0, MAX_PLAYERS - 1 do
						if gNetworkPlayers[n].connected then
							if strip_hex(currentNames[n]) == strip_hex(currentNames[i]) and n ~= i then
								local message = "\\#dcdcdc\\Impersonation may be happening, " .. previousNames[i] .. "\\#dcdcdc\\(" .. tostring(i) .. ") changed their name to " .. currentNames[i] .. "\\#dcdcdc\\(" .. tostring(i) ..  "), possibly impersonating " .. currentNames[n] .. "\\#dcdcdc\\(" .. tostring(n) .. ")"
								network_send(true, {message = message})
								djui_chat_message_create(message)
							end
						end
					end
				end
			end

			previousNames[i] = currentNames[i]
		else
			currentNames[i] = ""
			previousNames[i] = ""
		end
	end
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_PACKET_RECEIVE, on_recieve)
