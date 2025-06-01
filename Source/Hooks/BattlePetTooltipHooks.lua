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
		-- print(item)

		-- Inventorix.Tooltip:AddItemRanksSection(tooltipLines, item)
		-- Inventorix.Tooltip:AddItemPartsSection(tooltipLines, item.itemId)
		-- Inventorix.Tooltip:AddItemRecipesSection(tooltipLines, item.itemId)

		-- AddTooltipLines(tooltipLines)
	end
)
