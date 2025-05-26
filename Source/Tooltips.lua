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

TooltipHandlers["SetHyperlink"] = function (tooltip, itemLink)
	ShowTooltip(tooltip, itemLink)
end

-- Bank or bag in bag list
TooltipHandlers["GetInventoryItem"] = function(tooltip, unit, slot)
	local itemLink = GetInventoryItemLink(unit, slot)

	ShowTooltip(tooltip, itemLink)
end

TooltipHandlers["GetItemKey"] = function(tooltip, itemID, itemLevel, itemSuffix)
	local itemLink
	local info = C_TooltipInfo and C_TooltipInfo.GetItemKey(itemID, itemLevel, itemSuffix)

	if info == nil then
		return
	end

	itemLink = info.hyperlink

	if itemLink then
		ShowTooltip(tooltip, itemLink)
	end
end

-- Merchant window (Merchant Pane)
TooltipHandlers["GetMerchantItem"] = function(tooltip, index)
	local itemLink = GetMerchantItemLink(index)

	ShowTooltip(tooltip, itemLink)
end

if TooltipDataProcessor then
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

			if TooltipHandlers[info.getterName] == nil then
				print(info.getterName)
			end
			local handler = TooltipHandlers[info.getterName]
			if handler then
				handler(tooltip, unpack(info.getterArgs))
			end
		end
	end)
end
