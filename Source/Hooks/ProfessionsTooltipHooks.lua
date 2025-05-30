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
		local itemId = tonumber(string.match(itemLink, "item:(%d+)"))
		local tooltipLines = {}

		InventorixTooltip:AddItemCountSection(tooltipLines, itemId, "Inventory")
		InventorixTooltip:AddItemRanksSection(tooltipLines, itemId)
		InventorixTooltip:AddItemPartsSection(tooltipLines, itemId)
		InventorixTooltip:AddItemRecipesSection(tooltipLines, itemId)

		AddTooltipLines(tooltip, tooltipLines)

		tooltip:Show()
	end
end

-- Profession Window Tooltips
EventUtil.ContinueOnAddOnLoaded("Blizzard_ProfessionsTemplates", function()

	hooksecurefunc(Professions, "SetupQualityReagentTooltip", function(slot, transaction)
		-- print("SetupQualityReagentTooltip")
    -- local display = {}
    -- local quantities = Professions.GetQuantitiesAllocated(transaction, slot:GetReagentSlotSchematic())
    -- for index, reagentDetails in ipairs(slot:GetReagentSlotSchematic().reagents) do
    --   table.insert(display, {
    --     itemID = reagentDetails.itemID,
    --     quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(reagentDetails.itemID),
    --     itemCount = quantities[index],
    --   })
    -- end
    -- table.sort(display, function(a, b)
    --   return a.quality < b.quality
    -- end)

    -- AddReagentsAuctionTip(GameTooltip, display)
	end)

	hooksecurefunc(Professions, "AddCommonOptionalTooltipInfo", function(item)
		-- print("AddCommonOptionalTooltipInfo")
		-- Auctionator.Tooltip.AddReagentsAuctionTip(GameTooltip, {{itemID = item:GetItemID(), itemCount = 1}})



		-- Auctionator.Debug.Message("Auctionator.Tooltip.AddReagentsAuctionTip", speciesID)
		-- if not Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_TOOLTIPS) then
		-- 	return
		-- end

		-- local showStackPrices = IsShiftKeyDown();

		-- if not Auctionator.Config.Get(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS) then
		-- 	showStackPrices = not IsShiftKeyDown();
		-- end

		-- for _, reagent in ipairs(allReagents) do
		-- 	local itemInfo = { C_Item.GetItemInfo(reagent.itemID) };
		-- 	if not Auctionator.Utilities.IsBound(itemInfo) then
		-- 		local key = tostring(reagent.itemID)
		-- 		local auctionPrice = Auctionator.Database:GetPrice(key)
		-- 		local auctionAge = Auctionator.Database:GetPriceAge(key)
		-- 		local qualitySuffix = ""
		-- 		if reagent.quality then
		-- 			qualitySuffix = " " .. C_Texture.GetCraftingReagentQualityChatIcon(reagent.quality)
		-- 		end
		-- 		local countString = ""
		-- 		if showStackPrices then
		-- 			countString = Auctionator.Utilities.CreateCountString(reagent.itemCount)
		-- 		end
		-- 		if auctionPrice ~= nil then
		-- 			auctionPrice = auctionPrice * (showStackPrices and math.max(1, reagent.itemCount) or 1)
		-- 			tooltipFrame:AddDoubleLine(
		-- 				L("AUCTION") .. countString .. qualitySuffix,
		-- 				WHITE_FONT_COLOR:WrapTextInColorCode(
		-- 					Auctionator.Utilities.CreatePaddedMoneyString(auctionPrice)
		-- 				)
		-- 			)
		-- 		else
		-- 			tooltipFrame:AddDoubleLine(
		-- 				L("AUCTION") .. countString .. qualitySuffix,
		-- 				WHITE_FONT_COLOR:WrapTextInColorCode(L("UNKNOWN"))
		-- 			)
		-- 		end
		-- 	end
		-- end
	end)

end)





-- function AddReagentsAuctionTip(tooltipFrame, allReagents)
--   Auctionator.Debug.Message("Auctionator.Tooltip.AddReagentsAuctionTip", speciesID)
--   if not Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_TOOLTIPS) then
--     return
--   end

--   local showStackPrices = IsShiftKeyDown();

--   if not Auctionator.Config.Get(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS) then
--     showStackPrices = not IsShiftKeyDown();
--   end

--   for _, reagent in ipairs(allReagents) do
--     local itemInfo = { C_Item.GetItemInfo(reagent.itemID) };
--     if not Auctionator.Utilities.IsBound(itemInfo) then
--       local key = tostring(reagent.itemID)
--       local auctionPrice = Auctionator.Database:GetPrice(key)
--       local auctionAge = Auctionator.Database:GetPriceAge(key)
--       local qualitySuffix = ""
--       if reagent.quality then
--         qualitySuffix = " " .. C_Texture.GetCraftingReagentQualityChatIcon(reagent.quality)
--       end
--       local countString = ""
--       if showStackPrices then
--         countString = Auctionator.Utilities.CreateCountString(reagent.itemCount)
--       end
--       if auctionPrice ~= nil then
--         auctionPrice = auctionPrice * (showStackPrices and math.max(1, reagent.itemCount) or 1)
--         tooltipFrame:AddDoubleLine(
--           L("AUCTION") .. countString .. qualitySuffix,
--           WHITE_FONT_COLOR:WrapTextInColorCode(
--             Auctionator.Utilities.CreatePaddedMoneyString(auctionPrice)
--           )
--         )
--       else
--         tooltipFrame:AddDoubleLine(
--           L("AUCTION") .. countString .. qualitySuffix,
--           WHITE_FONT_COLOR:WrapTextInColorCode(L("UNKNOWN"))
--         )
--       end
--     end
--   end
-- end
