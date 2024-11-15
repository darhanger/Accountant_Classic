function AccountantButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(ACCLOC_TITLE);
	GameTooltipTextLeft1:SetTextColor(1, 1, 1);
	GameTooltip:AddLine(ACCLOC_TIP);
	GameTooltip:Show();
end;

function AccountantButton_OnClick()
	if AccountantFrame:IsVisible() then
		HideUIPanel(AccountantFrame);
	else
		ShowUIPanel(AccountantFrame);
	end
end;

function AccountantButton_Init()
	if(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showbutton) then
		AccountantButtonFrame:Show();
	else
		AccountantButtonFrame:Hide();
	end
end;

function AccountantButton_Toggle()
	if(AccountantButtonFrame:IsVisible()) then
		AccountantButtonFrame:Hide();
		Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showbutton = false;
	else
		AccountantButtonFrame:Show();
		Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showbutton = true;
	end
end;

function AccountantButton_UpdatePosition()
	AccountantButtonFrame:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		55 - (75 * cos(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].buttonpos)),
		(75 * sin(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].buttonpos)) - 55
	);
end;