local playerName = UnitName("player")

InventorixService = {
	accountItems = INVENTORIX_ACCOUNT_ITEM_STORE or {},
	playerItems = INVENTORIX_PLAYER_ITEM_STORE or {
		[playerName] = {},
	},
	playerName = playerName,
}

local saveDebounce = false
local updateContainerDebounce = {}

function InventorixService:GetItemCount(itemID)
	local itemCount = {
		Warband = 0,
		Total = 0,
	}

	for _, items in pairs(self.accountItems) do
		if items[itemID] then
			itemCount.Warband = itemCount.Warband + items[itemID]
			itemCount.Total = itemCount.Total + items[itemID]
		end
	end

	for playerName, containers in pairs(self.playerItems) do
		for _, items in pairs(containers) do
			if items[itemID] then
				itemCount[playerName] = (itemCount[playerName] or 0) + items[itemID]
				itemCount.Total = itemCount.Total + items[itemID]
			end
		end
	end

	return itemCount
end

function InventorixService:PrintInventoryItem(containerIndex, slotIndex)
	local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex)
	print(containerIndex, slotIndex, itemInfo.itemID or "no-id", itemInfo.stackCount or "no-count")
end

function InventorixService:Save()
	if not saveDebounce then
		saveDebounce = true
		C_Timer.After(5, function()
			INVENTORIX_ITEM_STORE = InventorixService.playerItems
			saveDebounce = false
		end)
	end
end

function InventorixService:SetItem(containerIndex, slotIndex)
	local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex)

	if itemInfo then
		if INVENTORIX_BAGS_TYPES[containerIndex] == "account" then
			self.accountItems[containerIndex][itemInfo.itemID] = (self.accountItems[containerIndex][itemInfo.itemID] or 0) + (itemInfo.stackCount or 1)
		else
			self.playerItems[self.playerName][containerIndex][itemInfo.itemID] = (self.playerItems[self.playerName][containerIndex][itemInfo.itemID] or 0) + (itemInfo.stackCount or 1)
		end
	end
end

function InventorixService:UpdateBags()
	for _, containerIndex in ipairs(INVENTORIX_INVENTORY_BAGS) do
		self:UpdateContainer(containerIndex)
	end
end

function InventorixService:UpdateBank()
	for _, containerIndex in ipairs(INVENTORIX_BANK_BAGS) do
		self:UpdateContainer(containerIndex)
	end
end

function InventorixService:UpdateContainer(containerIndex)
	if INVENTORIX_BAGS_TYPES[containerIndex] == "account" then
		self.accountItems[containerIndex] = {}
	else
		self.playerItems[self.playerName] = self.playerItems[self.playerName] or {}
		self.playerItems[self.playerName][containerIndex] = {}
	end

	if not updateContainerDebounce[containerIndex] then
		updateContainerDebounce[containerIndex] = true
		C_Timer.After(1, function()
			for slotIndex = 1, C_Container.GetContainerNumSlots(containerIndex) do
				InventorixService:SetItem(containerIndex, slotIndex)
			end
			InventorixService:Save()
			updateContainerDebounce[containerIndex] = false
		end)
	end
end
