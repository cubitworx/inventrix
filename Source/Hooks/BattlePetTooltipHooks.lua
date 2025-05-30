local LibBattlePetTooltipLine = LibStub("LibBattlePetTooltipLine-1-0")

local AddTooltipLines = function(lines)
	for _, line in ipairs(lines) do
		if #line == 1 then
			LibBattlePetTooltipLine:AddLine(BattlePetTooltip, line[1])
		else
			LibBattlePetTooltipLine:AddDoubleLine(BattlePetTooltip, line[1], line[2])
		end
	end
end

-- Battle Pets Inventory Tooltips
hooksecurefunc(_G, "BattlePetToolTip_Show",
	function(speciesID, ...)
		local tooltipLines = {}
		local itemId = speciesID;
		-- print(itemId)

		-- InventorixTooltip:AddItemCountSection(tooltipLines, itemId, "Inventory")
		-- InventorixTooltip:AddItemRanksSection(tooltipLines, itemId)
		-- InventorixTooltip:AddItemPartsSection(tooltipLines, itemId)
		-- InventorixTooltip:AddItemRecipesSection(tooltipLines, itemId)

		-- AddTooltipLines(tooltipLines)
	end
)
