function AccountantButton_AddTooltip(tooltip)
	if tooltip.ClearLines then tooltip:ClearLines(); end
	tooltip:AddLine("|cffffffff"..ACCLOC_TITLE.."|r  "..(Accountant_Version or ""));
	tooltip:AddLine(" ");
	tooltip:AddLine(ACCLOC_TIP, 1, 1, 1, true);
end;

function AccountantButton_OnClick()
	if AccountantFrame:IsVisible() then
		HideUIPanel(AccountantFrame);
	else
		ShowUIPanel(AccountantFrame);
	end
end;

function AccountantButton_Init()
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	if not options.minimap then
		options.minimap = {hide = not options.showbutton, minimapPos = 225};
	end
	local icon = LibStub("LibDBIcon-1.0");
	if not icon:IsRegistered("Accountant_Classic") then
		local broker = LibStub("LibDataBroker-1.1"):GetDataObjectByName("Accountant_Classic");
		icon:Register("Accountant_Classic", broker, options.minimap);
	else
		icon:Refresh("Accountant_Classic", options.minimap);
	end
end;

function AccountantButton_Toggle()
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	local db = options.minimap;
	local icon = LibStub("LibDBIcon-1.0");
	if db.hide then
		db.hide = false;
		icon:Show("Accountant_Classic");
	else
		db.hide = true;
		icon:Hide("Accountant_Classic");
	end
	options.showbutton = not db.hide;
end;
