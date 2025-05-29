local currentPlayerId = UnitGUID("player")

InventorixInventory = {
	playerItems = {},
	warbandItems = {},
}

local debounce = {
	save = false,
	updateContainer = {},
}

function InventorixInventory:GetItemRanks(itemId)
	return INVENTORIX_REAGENT_RANKS[Item:CreateFromItemID(itemId):GetItemName()]
end

function InventorixInventory:GetItemParts(itemId)
	return INVENTORIX_REAGENT_PARTS[itemId]
end

function InventorixInventory:GetItemRecipes(itemId)
	return INVENTORIX_TRADESKILL_RECIPES[itemId]
end

function InventorixInventory:GetItemCountPlayer(player, itemId)
	local itemCount = 0
	local playerItems = self.playerItems[player.playerId]

	for _, items in pairs(playerItems) do
		itemCount = (itemCount or 0) + (items[itemId] or 0)
	end

	return itemCount
end

function InventorixInventory:GetItemCountWarband(itemId)
	local itemCount = 0

	for _, items in pairs(self.warbandItems) do
		itemCount = itemCount + (items[itemId] or 0)
	end

	return itemCount
end

function InventorixInventory:Init()
	self.warbandItems = INVENTORIX_WARBAND_ITEM_STORE or {}
	self.playerItems = INVENTORIX_PLAYER_ITEM_STORE or {}
	self.playerItems[currentPlayerId] = self.playerItems[currentPlayerId] or {}

	InventorixPlayerRegistry:Init()
end

function InventorixInventory:PrintInventoryItem(containerIndex, slotIndex)
	local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex)
	print(containerIndex, slotIndex, itemInfo.itemID or "no-id", itemInfo.stackCount or "no-count")
end

function InventorixInventory:Save()
	if not debounce.save then
		debounce.save = true
		C_Timer.After(5, function()
			INVENTORIX_WARBAND_ITEM_STORE = InventorixInventory.warbandItems
			INVENTORIX_PLAYER_ITEM_STORE = InventorixInventory.playerItems
			debounce.save = false
		end)
	end
end

function InventorixInventory:SetItem(containerIndex, slotIndex)
	local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex)

	if itemInfo then
		if INVENTORIX_BAGS_TYPES[containerIndex] == "account" then
			self.warbandItems[containerIndex][itemInfo.itemID] = (self.warbandItems[containerIndex][itemInfo.itemID] or 0) + (itemInfo.stackCount or 1)
		else
			self.playerItems[currentPlayerId][containerIndex][itemInfo.itemID] = (self.playerItems[currentPlayerId][containerIndex][itemInfo.itemID] or 0) + (itemInfo.stackCount or 1)
		end
	end
end

function InventorixInventory:UpdateBags()
	for _, containerIndex in ipairs(INVENTORIX_INVENTORY_BAGS) do
		self:UpdateContainer(containerIndex)
	end
end

function InventorixInventory:UpdateBank()
	for _, containerIndex in ipairs(INVENTORIX_BANK_BAGS) do
		self:UpdateContainer(containerIndex)
	end
end

function InventorixInventory:UpdateContainer(containerIndex)
	if INVENTORIX_BAGS_TYPES[containerIndex] == "account" then
		self.warbandItems[containerIndex] = {}
	else
		self.playerItems[currentPlayerId] = self.playerItems[currentPlayerId] or {}
		self.playerItems[currentPlayerId][containerIndex] = {}
	end

	if not debounce.updateContainer[containerIndex] then
		debounce.updateContainer[containerIndex] = true
		C_Timer.After(1, function()
			for slotIndex = 1, C_Container.GetContainerNumSlots(containerIndex) do
				InventorixInventory:SetItem(containerIndex, slotIndex)
			end
			InventorixInventory:Save()
			debounce.updateContainer[containerIndex] = false
		end)
	end
end
