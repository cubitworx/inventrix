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
		InventorixService:UpdateBank()
	elseif event == "BAG_UPDATE" then
		InventorixService:UpdateContainer(...)
	elseif event == "PLAYER_ENTERING_WORLD" then
		InventorixService:UpdateBags()
	elseif event == "PLAYER_LOGIN" then
		InventorixService:Init()
	elseif event == "PLAYERBANKSLOTS_CHANGED" then
		InventorixService:UpdateBank()
	end
end)
