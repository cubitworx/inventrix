local TooltipHandlers = {}

local ShowTooltip = function(tooltip, itemLink)
	if itemLink then
		local itemID = tonumber(string.match(itemLink, "item:(%d+)"))

		for playerName, itemCount in pairs(InventorixService:GetItemCount(itemID)) do
			tooltip:AddLine(playerName .. ": " .. itemCount, 1, 1, 1)
			tooltip:Show()
		end
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

TooltipHandlers["GetItemKey"] = function(tooltip, itemID, itemLevel, itemSuffix)
	local info = C_TooltipInfo and C_TooltipInfo.GetItemKey(itemID, itemLevel, itemSuffix)

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

TooltipHandlers["GetRecipeReagentItem"] = function(tooltip, recipeID, slotID )
	local itemLink = C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, slotID)

	local recipeLevel
	if ProfessionsFrame.CraftingPage:IsVisible() then
		recipeLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetCurrentRecipeLevel()
	elseif ProfessionsFrame.OrdersPage:IsVisible() then
		recipeLevel =  ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:GetCurrentRecipeLevel()
	end

	local schematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)

	for _, reagentSlotSchematic in ipairs(schematic.reagentSlotSchematics) do
		if reagentSlotSchematic.dataSlotIndex == slotID then
			ShowTooltip(tooltip, itemLink)
			break
		end
	end
end

TooltipHandlers["GetRecipeResultItem"] = function(tooltip, recipeID, reagents, allocations, _, qualityID)
	local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents, allocations, qualityID)
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
		if not info or not info.getterName or info.excludeLines then
			return
		end

		-- if TooltipHandlers[info.getterName] == nil then
		-- 	print(info.getterName)
		-- end
		local handler = TooltipHandlers[info.getterName]
		if handler then
			handler(tooltip, unpack(info.getterArgs))
		end
	end
end)
