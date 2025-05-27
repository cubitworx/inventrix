local Inventorix = CreateFrame("Frame")

FrameUtil.RegisterFrameForEvents(Inventorix, {
	"BAG_UPDATE",
	"BANKFRAME_OPENED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LOGIN",
	"PLAYERBANKSLOTS_CHANGED",
})

Inventorix:SetScript("OnEvent", function(self, event, ...)
	if event == "BANKFRAME_OPENED" then
		InventorixInventory:UpdateBank()
	elseif event == "BAG_UPDATE" then
		InventorixInventory:UpdateContainer(...)
	elseif event == "PLAYER_ENTERING_WORLD" then
		InventorixInventory:UpdateBags()
	elseif event == "PLAYER_LOGIN" then
		InventorixInventory:Init()
	elseif event == "PLAYERBANKSLOTS_CHANGED" then
		InventorixInventory:UpdateBank()
	end
end)
