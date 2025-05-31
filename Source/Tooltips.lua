InventorixTooltip = {}

local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t"
local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t"
local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t"
local reagentColor = BRIGHTBLUE_FONT_COLOR
local valueColor = WHITE_FONT_COLOR
local warbandColor = FRAMESTACK_FRAME_COLOR
local rankIcons = {
	[1] = C_Texture.GetCraftingReagentQualityChatIcon(1),
	[2] = C_Texture.GetCraftingReagentQualityChatIcon(2),
	[3] = C_Texture.GetCraftingReagentQualityChatIcon(3),
}

function InventorixTooltip:AddItemCountSection(tooltipLines, itemId, sectionTitle)
	local totalCount = 0

	table.insert(tooltipLines, {" "})
	table.insert(tooltipLines, {sectionTitle})
	local titleLineIndex = #tooltipLines

	-- Warband
	local warbandCount = CLIB_Inventory:GetItemCount(CLIB_Inventory:GetWarbandItems(), itemId)
	totalCount = totalCount + warbandCount

	table.insert(tooltipLines, {warbandColor:WrapTextInColorCode("Warband "), valueColor:WrapTextInColorCode(warbandCount)})

	-- Players
	for _, player in ipairs(CLIB_PlayerRegistry.players) do
		local classColor = C_ClassColor.GetClassColor(player.classFilename)
		local itemCount = CLIB_Inventory:GetItemCount(CLIB_Inventory:GetPlayerItems(player), itemId)

		if itemCount > 0 then
			table.insert(tooltipLines, {classColor:WrapTextInColorCode(player.playerName), valueColor:WrapTextInColorCode(itemCount)})
			totalCount = totalCount + itemCount
		end
	end

	tooltipLines[titleLineIndex][2] = valueColor:WrapTextInColorCode(totalCount)
end

function InventorixTooltip:AddItemPartsSection(tooltipLines, itemId)
	local itemParts = CLIB_Constants:GetItemParts(itemId)

	if itemParts then
		for partItemId, title in pairs(itemParts) do
			self:AddItemCountSection(tooltipLines, partItemId, title)
		end
	end
end

function InventorixTooltip:AddItemRanksSection(tooltipLines, itemId)
	local itemRanks = CLIB_Constants:GetItemRanks(Item:CreateFromItemID(itemId):GetItemName())

	if itemRanks then
		for _, rankItemId in ipairs(itemRanks) do
			if rankItemId ~= itemId then
				self:AddItemCountSection(tooltipLines, rankItemId, self:GetItemNameWithRank(rankItemId))
			end
		end
	end
end

function InventorixTooltip:AddItemRecipesSection(tooltipLines, itemId)
	local itemRecipes = CLIB_Constants:GetItemRecipes(itemId)

	if itemRecipes then
		for _, recipe in pairs(itemRecipes) do
			local reagentCounts = {}

			table.insert(tooltipLines, {" "})
			table.insert(tooltipLines, {recipe.title .. " " .. self:QuantityString(recipe.qty)})

			-- Players
			for _, reagent in ipairs(recipe.reagents) do
				local reagentTitle = reagent.title .. " " .. self:QuantityString(reagent.qty)
				reagentCounts[reagentTitle] = reagentCounts[reagentTitle] or 0
				for _, player in ipairs(CLIB_PlayerRegistry.players) do
					reagentCounts[reagentTitle] = reagentCounts[reagentTitle] + (CLIB_Inventory:GetItemCount(CLIB_Inventory:GetPlayerItems(player), reagent.id) or 0)
				end
			end

			for reagentName, reagentCount in pairs(reagentCounts) do
				table.insert(tooltipLines, {reagentColor:WrapTextInColorCode(reagentName) .. " " .. valueColor:WrapTextInColorCode(reagentCount)})
			end
		end
	end
end

function InventorixTooltip:AddVendorPurchasePrice(tooltipLines, itemId)
	local vendorPurchasePrice = CLIB_Constants:GetVendorPurchasePrice(itemId)

	if vendorPurchasePrice then
		table.insert(tooltipLines, {vendorPurchasePrice["source"], valueColor:WrapTextInColorCode(self:MoneyString(vendorPurchasePrice["price"]))})
	end
end

function InventorixTooltip:GetItemNameWithRank(itemId)
	local rank = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemId)

	return Item:CreateFromItemID(itemId):GetItemName() .. (rank and " " .. rankIcons[rank] or "")
end

function InventorixTooltip:MoneyString(amount)
	amount = math.floor(amount)

	local copper = amount % 100
	local silver = (amount % 10000 - copper) / 100
	local gold = (amount - silver * 100 - copper) / 10000

	local result = copper .. " " .. copperIcon

	if copper < 10 and (gold ~= 0 or silver ~= 0) then
		result = "0" .. result
	end

	if silver ~= 0 or gold ~= 0 then
		result = silver .. " " .. silverIcon .. " " .. result
	end

	if gold ~= 0 and silver < 10 then
		result = "0" .. result
	end

	if gold ~= 0 then
		result = gold .. " " .. goldIcon .. " " .. result
	end

	return result
end

function InventorixTooltip:QuantityString(qty)
	return (qty == 1) and ""
		or (qty > 0 and "x" .. qty or "/" .. (1 / qty))
end
