ACCOUNTANT_OPTIONS_TITLE = ACCLOC_OPTS;

local Accountant_AboutBackdrop = {
	bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
};

function AccountantOptions_Toggle()
	if(InterfaceOptionsFrame:IsVisible()) then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory(AccountantOptionsFrame);
		InterfaceOptionsFrame_OpenToCategory(AccountantOptionsFrame);
	end
end;

function AccountantOptions_OnLoad(panel)
	UIPanelWindows['AccountantOptionsFrame'] = {area = 'center', pushable = 0};
	panel:SetBackdropColor(0.075, 0.102, 0.145, 0.92);
	panel:SetBackdropBorderColor(0.55, 0.55, 0.55, 1);
	local aboutLib = LibStub:GetLibrary("LibAboutPanel", true);
	if aboutLib then
		local about = aboutLib.new(nil, "Accountant_Classic", ACCLOC_TITLE);
		about:SetBackdrop(Accountant_AboutBackdrop);
		about:SetBackdropColor(0.075, 0.102, 0.145, 0.92);
		about:SetBackdropBorderColor(0.55, 0.55, 0.55, 1);
		panel.aboutFrame = about;
		panel.name = ACCLOC_SETTINGS;
		panel.parent = ACCLOC_TITLE;
	else
		panel.name = ACCLOC_TITLE;
	end
	InterfaceOptions_AddCategory(panel);
end;


function AccountantOptions_OnShow()
	AccountantOptionsFrameToggleButtonText:SetText(ACCLOC_MINIBUT);
	AccountantOptionsFrameMoneyInfoButtonText:SetText(ACCLOC_MONEYINFO);
	AccountantOptionsFrameMoneyIconsButtonText:SetText(ACCLOC_MONEYICONS);
	AccountantOptionsFrameWeekLabel:SetText(ACCLOC_STARTWEEK);

	AccountantOptionsFrameToggleButton:SetChecked(not Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].minimap.hide);
	AccountantOptionsFrameMoneyInfoButton:SetChecked(Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].showmoneyinfo);
	AccountantOptionsFrameMoneyIconsButton:SetChecked(Accountant_MoneyIcons);
	UIDropDownMenu_Initialize(AccountantOptionsFrameWeek, AccountantOptionsFrameWeek_Init);
	UIDropDownMenu_SetSelectedID(AccountantOptionsFrameWeek, Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].weekstart);
end;

function AccountantOptions_OnHide(self)
	if(MYADDONS_ACTIVE_OPTIONSFRAME == self) then
		ShowUIPanel(myAddOnsFrame);
	end
end;

function AccountantOptionsFrameWeek_Init()
	local info;
	Accountant_DayList = {ACCLOC_WD_SUN,ACCLOC_WD_MON,ACCLOC_WD_TUE,ACCLOC_WD_WED,ACCLOC_WD_THU,ACCLOC_WD_FRI,ACCLOC_WD_SAT};
	for i = 1, getn(Accountant_DayList), 1 do
		info = { };
		info.text = Accountant_DayList[i];
		info.func = AccountantOptionsFrameWeek_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end;

function AccountantOptionsFrameWeek_OnClick(self)
	UIDropDownMenu_SetSelectedID(AccountantOptionsFrameWeek, self:GetID());
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].weekstart = self:GetID();
	Accountant_CheckPeriods(true);
	if AccountantFrame:IsVisible() then Accountant_OnShow(); end
end;
