InventorixPlInventorixPlayerRegistryayer = {}

InventorixPlayerRegistry = {
	currentPlayer = {},
	players = {},
	playersById = {},
	playersByName = {},
	playerIdByName = {},
}

local debounce = {
	save = false,
}

function InventorixPlayerRegistry:Init()
	self.playersById = INVENTORIX_PLAYER_INFO_STORE or {}

	local currentPlayer = InventorixPlayer:CreateFromCurrentPlayer()
	self.currentPlayer = currentPlayer
	self.playersById[currentPlayer.playerId] = currentPlayer

	for playerId, player in pairs(self.playersById) do
		self.playerIdByName[player.playerName] = playerId;
		self.playersByName[currentPlayer.playerName] = player
		table.insert(self.players, player)
	end

	table.sort(self.players, function(a, b) return a.playerName < b.playerName end)

	self:Save()
end

function InventorixPlayerRegistry:GetPlayer(player)
	return self.playersById[player] or self.playersByName[player]
end

function InventorixPlayerRegistry:GetPlayerId(playerName)
	return self.playerIdByName[playerName]
end

function InventorixPlayerRegistry:GetPlayerName(playerId)
	return self.playersById[playerId] and self.playersById[playerId].playerName
end

function InventorixPlayerRegistry:Save()
	if not debounce.save then
		debounce.save = true
		C_Timer.After(5, function()
			INVENTORIX_PLAYER_INFO_STORE = InventorixPlayerRegistry.playersById
			debounce.save = false
		end)
	end
end
