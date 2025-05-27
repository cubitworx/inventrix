InventorixPlayer = {
	classFilename = nil,
	classId = nil,
	className = nil,
	playerId = nil,
	playerName = nil,
	realmId = nil,
	realmName = nil,
}

function InventorixPlayer:CreateFromCurrentPlayer()
	local currentPlayerId = UnitGUID("player")
	local currentPlayerName = UnitName("player")
	local className, classFilename, classId = C_PlayerInfo.GetClass({unit = "player"})

	return CreateFromMixins(self, {
		classFilename = classFilename,
		classId = classId,
		className = className,
		playerId = currentPlayerId,
		playerName = currentPlayerName,
	})
end
