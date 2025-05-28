local TooltipHandlers = {}

local labelColor = FRAMESTACK_FRAME_COLOR
local valueColor = WHITE_FONT_COLOR

local TooltipPlayerCount = function(player, itemCount)
	local classColor = C_ClassColor.GetClassColor(player.classFilename)

	return classColor:WrapTextInColorCode(player.playerName)
		.. " " .. valueColor:WrapTextInColorCode(itemCount)
end

local AddTooltipItemCountSection = function(tooltip, itemId, sectionTitle)
	local totalCount = 0

	-- Player
	local tooltipLines = {}
	for _, player in ipairs(InventorixPlayerRegistry.players) do
		local itemCount = InventorixInventory:GetItemCountPlayer(player, itemId)
		if itemCount > 0 then
			totalCount = totalCount + itemCount
			table.insert(tooltipLines, TooltipPlayerCount(player, itemCount))
		end
	end

	-- Warband
	local warbandCount = InventorixInventory:GetItemCountWarband(itemId)
	totalCount = totalCount + warbandCount

	tooltip:AddLine(" ")
	tooltip:AddDoubleLine(sectionTitle, labelColor:WrapTextInColorCode("Total ") .. valueColor:WrapTextInColorCode(totalCount))
	tooltip:AddDoubleLine(tooltipLines[1] or " ", labelColor:WrapTextInColorCode("Warband ") .. valueColor:WrapTextInColorCode(warbandCount))

	for index, leftText in ipairs(tooltipLines) do
		if index > 1 then
			tooltip:AddDoubleLine(leftText, rightText)
		end
	end
end

local ShowTooltip = function(tooltip, itemLink)
	if itemLink then
		local itemId = tonumber(string.match(itemLink, "item:(%d+)"))
		local similarItems = InventorixInventory:GetSimilarItems(itemId)

		AddTooltipItemCountSection(tooltip, itemId, "Inventory")

		if similarItems then
			for rank, similarItemId in ipairs(similarItems) do
				if similarItemId ~= itemId then
					AddTooltipItemCountSection(tooltip, similarItemId, "Rank " .. rank)
				end
			end
		end

		tooltip:Show()
	end
end

-- Bags
TooltipHandlers["GetBagItem"] = function(tooltip, bag, slot)
	local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)

	if C_Item.DoesItemExist(itemLocation) then
		local itemLink = C_Item.GetItemLink(itemLocation);

		ShowTooltip(tooltip, itemLink)
	end
end

-- Merchant (Buyback Pane)
TooltipHandlers["GetBuybackItem"] = function(tooltip, slotIndex)
	local itemLink = GetBuybackItemLink(slotIndex)

	ShowTooltip(tooltip, itemLink)
end

TooltipHandlers["GetHyperlink"] = function (tooltip, itemLink)
	ShowTooltip(tooltip, itemLink)
end

-- Bank or bag in bag list
TooltipHandlers["GetInventoryItem"] = function(tooltip, unit, slot)
	local itemLink = GetInventoryItemLink(unit, slot)

	ShowTooltip(tooltip, itemLink)
end

TooltipHandlers["GetItemKey"] = function(tooltip, itemId, itemLevel, itemSuffix)
	local info = C_TooltipInfo and C_TooltipInfo.GetItemKey(itemId, itemLevel, itemSuffix)

	if info then
		local itemLink = info.hyperlink

		if itemLink then
			ShowTooltip(tooltip, itemLink)
		end
	end
end

-- Merchant window (Merchant Pane)
TooltipHandlers["GetMerchantItem"] = function(tooltip, index)
	local itemLink = GetMerchantItemLink(index)

	ShowTooltip(tooltip, itemLink)
end

TooltipHandlers["GetRecipeReagentItem"] = function(tooltip, recipeId, slotId )
	local itemLink = C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeId, slotId)

	local recipeLevel
	if ProfessionsFrame.CraftingPage:IsVisible() then
		recipeLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetCurrentRecipeLevel()
	elseif ProfessionsFrame.OrdersPage:IsVisible() then
		recipeLevel =  ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:GetCurrentRecipeLevel()
	end

	local schematic = C_TradeSkillUI.GetRecipeSchematic(recipeId, false, recipeLevel)

	for _, reagentSlotSchematic in ipairs(schematic.reagentSlotSchematics) do
		if reagentSlotSchematic.dataSlotIndex == slotId then
			ShowTooltip(tooltip, itemLink)
			break
		end
	end
end

TooltipHandlers["GetRecipeResultItem"] = function(tooltip, recipeId, reagents, allocations, _, qualityId)
	local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeId, reagents, allocations, qualityId)
	local itemLink = outputInfo and outputInfo.hyperlink

	if itemLink then
		ShowTooltip(tooltip, itemLink)
	end
end

local function ValidateTooltip(tooltip)
	return tooltip == GameTooltip
		or tooltip == GameTooltipTooltip
		or tooltip == ItemRefTooltip
		or tooltip == GarrisonShipyardMapMissionTooltipTooltip
		or (not tooltip:IsForbidden()
			and (tooltip:GetName() or ""):match("^NotGameTooltip"))
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
	if ValidateTooltip(tooltip) then
		local info = tooltip.info or tooltip.processingInfo
		if info and info.getterName and not info.excludeLines then
			-- if TooltipHandlers[info.getterName] == nil then
			-- 	print(info.getterName)
			-- end
			local handler = TooltipHandlers[info.getterName]
			if handler then
				handler(tooltip, unpack(info.getterArgs))
			end
		end
	end
end)
