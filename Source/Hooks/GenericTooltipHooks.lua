local TooltipHandlers = {}

local AddTooltipLines = function(tooltip, lines)
	for _, line in ipairs(lines) do
		if #line == 1 then
			tooltip:AddLine(line[1])
		else
			tooltip:AddDoubleLine(line[1], line[2])
		end
	end
end

local ShowTooltip = function(tooltip, itemLink)
	if itemLink then
		local item = Inventorix.Item:CreateFromItemLink(itemLink)
		local tooltipLines = {}

		Inventorix.Tooltip:AddVendorPurchasePrice(tooltipLines, item.itemId)
		Inventorix.Tooltip:AddItemRanksSection(tooltipLines, item)
		Inventorix.Tooltip:AddItemPartsSection(tooltipLines, item.itemId)
		Inventorix.Tooltip:AddItemRecipesSection(tooltipLines, item.itemId)

		AddTooltipLines(tooltip, tooltipLines)

		tooltip:Show()
	end
end

local ValidateTooltip = function(tooltip)
	return tooltip == GameTooltip
		or tooltip == GameTooltipTooltip
		or tooltip == ItemRefTooltip
		or tooltip == GarrisonShipyardMapMissionTooltipTooltip
		or (not tooltip:IsForbidden()
			and (tooltip:GetName() or ""):match("^NotGameTooltip"))
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
	if ProfessionsFrame and ProfessionsFrame.CraftingPage:IsVisible() then
		recipeLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetCurrentRecipeLevel()
	elseif ProfessionsFrame and ProfessionsFrame.OrdersPage:IsVisible() then
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

-- Generic Inventory Tooltips
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
