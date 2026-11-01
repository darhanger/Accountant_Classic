Accountant_Version = GetAddOnMetadata("Accountant_Classic", "Version");
Accountant_Data = nil;
Accountant_Disabled = false;
Accountant_Mode = "";
Accountant_CurrentMoney = 0;
Accountant_LastMoney = 0;
Accountant_Verbose = nil;
Accountant_GotName = false;
Accountant_CurrentTab = 1;
Accountant_MoneyIcons = false;
Accountant_LogModes = {"Session","Day","Week","Total",[6]="Month",[7]="Year"};
Accountant_Player = "";
Accountant_Server = "";
local Accountant_PendingLoot = 0;
local Accountant_PendingLootTime = 0;
local Accountant_LastMoneyChange = 0;
local Accountant_LastMoneyDiff = 0;
local Accountant_RepairAllItems_old;
local Accountant_CursorHasItem_old;

local function Accountant_MoneyPattern(amountFormat)
	local escaped = string.gsub(amountFormat, "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1");
	local pattern, count = string.gsub(escaped, "%%%%d", "(%%d+)");
	return count > 0 and pattern or "(%d+)"..escaped;
end

local Accountant_GoldAmountPattern = Accountant_MoneyPattern(GOLD_AMOUNT);
local Accountant_SilverAmountPattern = Accountant_MoneyPattern(SILVER_AMOUNT);
local Accountant_CopperAmountPattern = Accountant_MoneyPattern(COPPER_AMOUNT);

function Accountant_RegisterEvents(self)
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("MERCHANT_CLOSED");
	self:RegisterEvent("MERCHANT_UPDATE");

	self:RegisterEvent("QUEST_COMPLETE");
	self:RegisterEvent("QUEST_FINISHED");

	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_CLOSED");

	self:RegisterEvent("TAXIMAP_OPENED");
	self:RegisterEvent("TAXIMAP_CLOSED");

	self:RegisterEvent("TRADE_SHOW");
	self:RegisterEvent("TRADE_CLOSED");

	self:RegisterEvent("MAIL_SHOW");
	self:RegisterEvent("MAIL_CLOSED");

	self:RegisterEvent("TRAINER_SHOW");
	self:RegisterEvent("TRAINER_CLOSED");

	self:RegisterEvent("AUCTION_HOUSE_SHOW");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");
	self:RegisterEvent("GUILDBANKFRAME_OPENED");
	self:RegisterEvent("GUILDBANKFRAME_CLOSED");
	self:RegisterEvent("BARBER_SHOP_OPEN");
	self:RegisterEvent("BARBER_SHOP_CLOSE");

	self:RegisterEvent("CHAT_MSG_MONEY");

	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("PLAYER_LOGOUT");

	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function Accountant_SetLabels(self)
	-- if current tab is All Chars tab
	if Accountant_CurrentTab == 5 then
		AccountantFrameSource:SetText(ACCLOC_CHAR);
		AccountantFrameIn:SetText(ACCLOC_MONEY);
		AccountantFrameOut:SetText(ACCLOC_UPDATED);
		AccountantFrameTotalIn:SetText(ACCLOC_SUM..":");
		AccountantFrameTotalOut:SetText("");
		AccountantFrameTotalFlow:SetText("");
		AccountantFrameTotalInValue:SetText("");
		AccountantFrameTotalOutValue:SetText("");
		AccountantFrameTotalFlowValue:SetText("");
		for i = 1, 15, 1 do
			_G["AccountantFrameRow"..i.."Title"]:SetText("");
			_G["AccountantFrameRow"..i.."Title"]:SetPoint("TOPLEFT", 3, -2);
			_G["AccountantFrameRow"..i.."In"]:SetText("");
			_G["AccountantFrameRow"..i.."Out"]:SetText("");
		end
		AccountantFrameResetButton:Hide();
		return;
	else
		AccountantFrameResetButton:Show();

		AccountantFrameSource:SetText(ACCLOC_SOURCE);
		AccountantFrameIn:SetText(ACCLOC_IN);
		AccountantFrameOut:SetText(ACCLOC_OUT);
		AccountantFrameTotalIn:SetText(ACCLOC_TOT_IN..":");
		AccountantFrameTotalOut:SetText(ACCLOC_TOT_OUT..":");
		AccountantFrameTotalFlow:SetText(ACCLOC_NET..":");

		-- Row Labels (auto generate)
		local InPos = 1
		for key,value in pairs(Accountant_Data) do
			Accountant_Data[key].InPos = InPos;
			_G["AccountantFrameRow"..InPos.."Title"]:SetText(Accountant_Data[key].Title);
			_G["AccountantFrameRow"..InPos.."Title"]:SetPoint("TOPLEFT", 3, -2);
			InPos = InPos + 1;
		end

		-- Set the header
		local name = AccountantFrame:GetName();
		local header = _G[name.."TitleText"];
		if ( header ) then
			header:SetText(ACCLOC_TITLE);
		end
	end
end

function Accountant_OnLoad(self)

	Accountant_Player = UnitName("player");
	Accountant_Server = GetRealmName();

	-- Setup
	Accountant_LoadData();
	Accountant_FrameInitPosition();
	Accountant_SetLabels();

	-- Current Cash
	Accountant_CurrentMoney = GetMoney();
	Accountant_LastMoney = Accountant_CurrentMoney;
	Accountant_MoneyInfoInit();

	-- Slash Commands
	SlashCmdList["ACCOUNTANT"] = Accountant_Slash;
	SLASH_ACCOUNTANT1 = "/accountant";
	SLASH_ACCOUNTANT2 = "/acc";

	-- Add myAddOns support
	if myAddOnsList then
		myAddOnsList.Accountant = {name = "Accountant", description = "Tracks your incomings / outgoings", version = Accountant_Version, frame = "AccountantFrame", optionsframe = "AccountantFrame"};
	end

	-- Confirm box
	StaticPopupDialogs["ACCOUNTANT_RESET"] = {
		text = TEXT("meh"),
		button1 = TEXT(OKAY),
		button2 = TEXT(CANCEL),
		OnAccept = function()
			Accountant_ResetConfirmed();
		end,
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		interruptCinematic = 1
	};

	-- hooks
	Accountant_RepairAllItems_old = RepairAllItems;
	RepairAllItems = Accountant_RepairAllItems;
--	Accountant_CursorHasItem_old = CursorHasItem;
--	CursorHasItem = Accountant_CursorHasItem;

	-- tabs
	AccountantFrameTab1:SetText(ACCLOC_SESS);
	PanelTemplates_TabResize(AccountantFrameTab1, 10);
	AccountantFrameTab2:SetText(ACCLOC_DAY);
	PanelTemplates_TabResize(AccountantFrameTab2, 10);
	AccountantFrameTab3:SetText(ACCLOC_WEEK);
	PanelTemplates_TabResize(AccountantFrameTab3, 10);
	AccountantFrameTab4:SetText(ACCLOC_TOTAL);
	PanelTemplates_TabResize(AccountantFrameTab4, 10);
	AccountantFrameTab5:SetText(ACCLOC_CHARS);
	PanelTemplates_TabResize(AccountantFrameTab5, 10);
	AccountantFrameTab6:SetText(ACCLOC_MONTH);
	PanelTemplates_TabResize(AccountantFrameTab6, 10);
	AccountantFrameTab7:SetText(ACCLOC_YEAR);
	PanelTemplates_TabResize(AccountantFrameTab7, 10);
	PanelTemplates_SetNumTabs(AccountantFrame, 7);
	PanelTemplates_SetTab(AccountantFrame, AccountantFrameTab1);
	PanelTemplates_UpdateTabs(AccountantFrame);

	ACC_Print(ACCLOC_TITLE.." "..ACCLOC_LOADED);

	--Make an LDB object
	LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Accountant_Classic", {
		type = "launcher",
		text = ACCLOC_TITLE,
		OnClick = function(_, msg)
			if msg == "LeftButton" then
				AccountantButton_OnClick();
			elseif msg == "RightButton" then
				AccountantOptions_Toggle();
			end
		end,
		icon = "Interface\\Icons\\INV_Misc_Coin_01",
		OnTooltipShow = function(tooltip)
			if tooltip and tooltip.AddLine then AccountantButton_AddTooltip(tooltip); end
		end,
	});

	if ( TitanPanelButton_UpdateButton ) then
		TitanPanelButton_UpdateButton("Accountant_Classic");
	end
end

function Accountant_LoadData()
	Accountant_Data = {};
	Accountant_Data["TRAIN"] = 	{Title = ACCLOC_TRAIN};
	Accountant_Data["TAXI"] = 	{Title = ACCLOC_TAXI};
	Accountant_Data["TRADE"] = 	{Title = ACCLOC_TRADE};
	Accountant_Data["AH"] = 	{Title = ACCLOC_AUC};
	Accountant_Data["MERCH"] = 	{Title = ACCLOC_MERCH};
	Accountant_Data["REPAIRS"] = 	{Title = ACCLOC_REPAIR};
	Accountant_Data["MAIL"] = 	{Title = ACCLOC_MAIL};
	Accountant_Data["QUEST"] = 	{Title = ACCLOC_QUEST};
	Accountant_Data["LOOT"] = 	{Title = ACCLOC_LOOT};
	Accountant_Data["OTHER"] = 	{Title = ACCLOC_OTHER};
	Accountant_Data["GUILD"] = 	{Title = ACCLOC_GUILD};
	Accountant_Data["BARBER"] = 	{Title = ACCLOC_BARBER};

	for key,value in pairs(Accountant_Data) do
		for modekey,mode in pairs(Accountant_LogModes) do
			Accountant_Data[key][mode] = {In=0,Out=0};
		end
	end

	if(Accountant_SaveData == nil) then
		Accountant_SaveData = {};
	end
	if (Accountant_SaveData[Accountant_Server] == nil) then
		Accountant_SaveData[Accountant_Server] = {};
	end
	if (Accountant_SaveData[Accountant_Server][Accountant_Player] == nil ) then
		Accountant_SaveData[Accountant_Server][Accountant_Player] = {options={showbutton=true,version=Accountant_Version,date=date("%Y-%m-%d"),weekstart=1,totalcash=0},data={}};
		ACC_Print(ACCLOC_NEWPROFILE.." "..Accountant_Player);
	else
		ACC_Print(ACCLOC_LOADPROFILE.." "..Accountant_Player);
	end
	local profile = Accountant_SaveData[Accountant_Server][Accountant_Player];
	profile.options = profile.options or {};
	profile.data = profile.data or {};
	if profile.options.showbutton == nil then profile.options.showbutton = true; end
	if profile.options.showmoneyinfo == nil then profile.options.showmoneyinfo = false; end
	if profile.options.moneyicons == nil then profile.options.moneyicons = false; end
	Accountant_MoneyIcons = profile.options.moneyicons == true;

	local order = 1;
	for key,value in pairs(Accountant_Data) do
		if profile.data[key] == nil then
			profile.data[key] = {}
		end
		local savedCategory = profile.data[key];
		if savedCategory.TotalIn ~= nil or savedCategory.TotalOut ~= nil then
			savedCategory.Total = savedCategory.Total or {In=0,Out=0};
			if savedCategory.TotalIn ~= nil then
				savedCategory.Total.In = savedCategory.TotalIn;
				savedCategory.TotalIn = nil;
			end
			if savedCategory.TotalOut ~= nil then
				savedCategory.Total.Out = savedCategory.TotalOut;
				savedCategory.TotalOut = nil;
			end
		end
		for modekey,mode in pairs(Accountant_LogModes) do
			if savedCategory[mode] == nil then
				savedCategory[mode] = {In=0,Out=0};
			end
			savedCategory[mode].In = savedCategory[mode].In or 0;
			savedCategory[mode].Out = savedCategory[mode].Out or 0;
			Accountant_Data[key][mode].In = savedCategory[mode].In;
			Accountant_Data[key][mode].Out = savedCategory[mode].Out;
		end
		Accountant_Data[key]["Session"].In = 0;
		Accountant_Data[key]["Session"].Out = 0;

		Accountant_Data[key].order = order;
		order = order + 1;
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].version = Accountant_Version;
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].totalcash = GetMoney();

	if type(profile.options.weekstart) ~= "number" or profile.options.weekstart < 1 or profile.options.weekstart > 7 or profile.options.weekstart % 1 ~= 0 then
		Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["weekstart"] = 3;
	end
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] == nil then
		Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] = Accountant_WeekStart();
	end
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] == nil then
		Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] = date("%Y-%m-%d");
	end
	if profile.options.datemonth == nil then profile.options.datemonth = date("%Y-%m"); end
	if profile.options.dateyear == nil then profile.options.dateyear = date("%Y"); end
	Accountant_CheckPeriods();
	
end

function Accountant_Slash(msg)
	if msg == nil or msg == "" then
		msg = "log";
	end
	local args = {n=0}
	local function helper(word) table.insert(args, word) end
	string.gsub(msg, "[_%w]+", helper);
	if args[1] == 'log'  then
		ShowUIPanel(AccountantFrame);
	elseif args[1] == 'verbose' then
		if Accountant_Verbose == nil then
			Accountant_Verbose = 1;
			ACC_Print("Verbose Mode On");
		else
			Accountant_Verbose = nil;
			ACC_Print("Verbose Mode Off");
		end
	elseif args[1] == 'week' then
		ACC_Print(Accountant_WeekStart());
	else
		Accountant_ShowUsage();
	end
end

function Accountant_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	local oldmode = Accountant_Mode;
	if ( event == "UNIT_NAME_UPDATE" and arg1 == "player" ) or (event=="PLAYER_ENTERING_WORLD") then
		if (Accountant_GotName) then
			return;
		end
		local playerName = UnitName("player");
		if ( playerName ~= UNKNOWNBEING and playerName ~= UNKNOWNOBJECT and playerName ~= nil ) then
			Accountant_GotName = true;
			Accountant_OnLoad();
			--AccountantOptions_OnLoad();
			AccountantButton_Init();
		end
		return;
	end
	if event == "MERCHANT_SHOW" then
		Accountant_Mode = "MERCH";
	elseif event == "MERCHANT_CLOSED" then
		Accountant_Mode = "";
	elseif event == "MERCHANT_UPDATE" then
		if (InRepairMode() == true) then
			Accountant_Mode = "REPAIRS";
		end
	elseif event == "TAXIMAP_OPENED" then
		Accountant_Mode = "TAXI";
	elseif event == "TAXIMAP_CLOSED" then
		if Accountant_Mode == "TAXI" then Accountant_Mode = ""; end
	elseif event == "LOOT_OPENED" then
		Accountant_Mode = "LOOT";
	elseif event == "LOOT_CLOSED" then
		if Accountant_Mode == "LOOT" then Accountant_Mode = ""; end
	elseif event == "TRADE_SHOW" then
		Accountant_Mode = "TRADE";
	elseif event == "TRADE_CLOSED" then
		Accountant_Mode = "";
	elseif event == "QUEST_COMPLETE" then
		Accountant_Mode = "QUEST";
	elseif event == "QUEST_FINISHED" then
		if Accountant_Mode == "QUEST" then Accountant_Mode = ""; end
	elseif event == "MAIL_SHOW" then
		Accountant_Mode = "MAIL";
	elseif event == "MAIL_CLOSED" then
		Accountant_Mode = "";
	elseif event == "TRAINER_SHOW" then
		Accountant_Mode = "TRAIN";
	elseif event == "TRAINER_CLOSED" then
		Accountant_Mode = "";
	elseif event == "AUCTION_HOUSE_SHOW" then
		Accountant_Mode = "AH";
	elseif event == "AUCTION_HOUSE_CLOSED" then
		Accountant_Mode = "";
	elseif event == "GUILDBANKFRAME_OPENED" then
		Accountant_Mode = "GUILD";
	elseif event == "GUILDBANKFRAME_CLOSED" then
		if Accountant_Mode == "GUILD" then Accountant_Mode = ""; end
	elseif event == "BARBER_SHOP_OPEN" then
		Accountant_Mode = "BARBER";
	elseif event == "BARBER_SHOP_CLOSE" then
		if Accountant_Mode == "BARBER" then Accountant_Mode = ""; end
	elseif event == "PLAYER_MONEY" then
		if not Accountant_GotName then return; end
		local currentMoney = GetMoney();
		local oldMode = Accountant_Mode;
		local lootOverride = Accountant_PendingLoot > 0 and currentMoney - Accountant_LastMoney == Accountant_PendingLoot and GetTime() - Accountant_PendingLootTime <= 1;
		if lootOverride then
			Accountant_Mode = "LOOT";
		end
		Accountant_PendingLoot = 0;
		Accountant_UpdateLog(currentMoney);
		if lootOverride then Accountant_Mode = oldMode; end
	elseif event == "PLAYER_LOGOUT" then
		if Accountant_GotName then
			Accountant_SaveData[Accountant_Server][Accountant_Player].options.totalcash = Accountant_LastMoney;
		end
-- This event is supposed to be fired before PLAYER_MONEY.
	elseif event == "CHAT_MSG_MONEY" then
		Accountant_OnShareMoney(arg1);
	end
	if Accountant_Verbose and Accountant_Mode ~= oldmode then ACC_Print("Accountant mode changed to '"..Accountant_Mode.."'"); end
end

function Accountant_OnShareMoney(arg1)
	if not Accountant_GotName or not arg1 then return; end
	local gold = tonumber(string.match(arg1, Accountant_GoldAmountPattern)) or 0;
	local silver = tonumber(string.match(arg1, Accountant_SilverAmountPattern)) or 0;
	local copper = tonumber(string.match(arg1, Accountant_CopperAmountPattern)) or 0;
	local money = copper + silver * 100 + gold * 10000;
	if money == 0 then return; end

	local currentMoney = GetMoney();
	if currentMoney - Accountant_LastMoney == money then
		Accountant_PendingLoot = 0;
		local oldMode = Accountant_Mode;
		Accountant_Mode = "LOOT";
		Accountant_UpdateLog(currentMoney);
		Accountant_Mode = oldMode;
	elseif currentMoney == Accountant_LastMoney and not (Accountant_LastMoneyDiff == money and GetTime() - Accountant_LastMoneyChange <= 1) then
		Accountant_PendingLoot = money;
		Accountant_PendingLootTime = GetTime();
	end
end


local Accountant_GoldIcon = "|TInterface\\MoneyFrame\\UI-MoneyIcons:14:14:0:0:64:16:0:16:0:16|t";
local Accountant_SilverIcon = "|TInterface\\MoneyFrame\\UI-MoneyIcons:14:14:0:0:64:16:16:32:0:16|t";
local Accountant_CopperIcon = "|TInterface\\MoneyFrame\\UI-MoneyIcons:14:14:0:0:64:16:32:48:0:16|t";

function Accountant_NiceCash(amount)
	if Accountant_MoneyIcons then
		if amount <= 0 then return ""; end
		local gold = math.floor(amount / 10000);
		local silver = math.floor((amount - gold * 10000) / 100);
		local copper = amount - gold * 10000 - silver * 100;
		if gold > 0 then
			return gold.." "..Accountant_GoldIcon.." "..silver.." "..Accountant_SilverIcon.." "..copper.." "..Accountant_CopperIcon;
		elseif silver > 0 then
			return silver.." "..Accountant_SilverIcon.." "..copper.." "..Accountant_CopperIcon;
		end
		return copper.." "..Accountant_CopperIcon;
	end
	local agold = 10000;
	local asilver = 100;
	local outstr = "";
	local gold = 0;
	local silver = 0;
	local cent = 0;

	if amount >= agold then
		gold = math.floor(amount / agold);
		outstr = "|cFFFFFF00" .. gold .. ACCLOC_GOLD;
	end
	amount = amount - (gold * agold);
	if amount >= asilver then
		silver = math.floor(amount / asilver);
		if silver < 10 then
			silver = " "..silver;
		end
		outstr = outstr .. "|cFFCCCCCC" .. silver .. ACCLOC_SILVER;
	end
	amount = amount - (silver * asilver);
	if amount > 0 then
		cent = amount;
		if cent < 10 then
			cent = " "..cent;
		end
		outstr = outstr .. "|cFFFF6600" .. cent .. ACCLOC_CENT;
	end
	return outstr;
end

local function Accountant_MoneyInfoCash(amount)
	local money = Accountant_NiceCash(amount);
	if money == "" then
		return Accountant_MoneyIcons and "0 "..Accountant_CopperIcon or "0"..ACCLOC_CENT;
	end
	return money;
end

function Accountant_MoneyInfoUpdate()
	if AccountantMoneyInfoFrame:IsShown() then
		AccountantMoneyInfoFrameText:SetText(Accountant_MoneyInfoCash(Accountant_CurrentMoney));
	end
end

function Accountant_MoneyInfoOnEnter(self)
	Accountant_CheckPeriods();
	local totalIn, totalOut = 0, 0;
	for _, category in pairs(Accountant_Data) do
		totalIn = totalIn + category.Day.In;
		totalOut = totalOut + category.Day.Out;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:ClearLines();
	GameTooltip:AddLine(ACCLOC_TITLE, 1, 0.82, 0);
	GameTooltip:AddLine(ACCLOC_DAY, 1, 0.82, 0);
	GameTooltip:AddDoubleLine(ACCLOC_IN, Accountant_MoneyInfoCash(totalIn), 0.4, 1, 0.4, 1, 1, 1);
	GameTooltip:AddDoubleLine(ACCLOC_OUT, Accountant_MoneyInfoCash(totalOut), 1, 0.4, 0.4, 1, 1, 1);

	local net = totalIn - totalOut;
	if net > 0 then
		GameTooltip:AddDoubleLine(ACCLOC_NETPROF, Accountant_MoneyInfoCash(net), 0.4, 1, 0.4, 1, 1, 1);
	elseif net < 0 then
		GameTooltip:AddDoubleLine(ACCLOC_NETLOSS, Accountant_MoneyInfoCash(-net), 1, 0.4, 0.4, 1, 1, 1);
	else
		GameTooltip:AddDoubleLine(ACCLOC_NET, Accountant_MoneyInfoCash(0), 1, 1, 1, 1, 1, 1);
	end
	GameTooltip:Show();
end

function Accountant_MoneyIconsToggle()
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	Accountant_MoneyIcons = not Accountant_MoneyIcons;
	options.moneyicons = Accountant_MoneyIcons;
	Accountant_MoneyInfoUpdate();
	if AccountantFrame:IsVisible() then Accountant_OnShow(); end
end

function Accountant_MoneyInfoInit()
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	if type(options.moneyX) == "number" and type(options.moneyY) == "number" then
		AccountantMoneyInfoFrame:ClearAllPoints();
		AccountantMoneyInfoFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", options.moneyX, options.moneyY);
	end
	if options.showmoneyinfo then
		AccountantMoneyInfoFrame:Show();
		Accountant_MoneyInfoUpdate();
	else
		AccountantMoneyInfoFrame:Hide();
	end
end

function Accountant_MoneyInfoToggle()
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	options.showmoneyinfo = not options.showmoneyinfo;
	if options.showmoneyinfo then
		AccountantMoneyInfoFrame:Show();
		Accountant_MoneyInfoUpdate();
	else
		AccountantMoneyInfoFrame:Hide();
	end
end

function Accountant_MoneyInfoSavePosition()
	local left, top = AccountantMoneyInfoFrame:GetLeft(), AccountantMoneyInfoFrame:GetTop();
	local parentLeft, parentTop = UIParent:GetLeft(), UIParent:GetTop();
	if not left or not top or not parentLeft or not parentTop then return; end
	local x, y = left - parentLeft, top - parentTop;
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	options.moneyX = x;
	options.moneyY = y;
	AccountantMoneyInfoFrame:ClearAllPoints();
	AccountantMoneyInfoFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y);
end

function Accountant_FrameInitPosition()
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	if type(options.frameX) == "number" and type(options.frameY) == "number" then
		AccountantFrame:ClearAllPoints();
		AccountantFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", options.frameX, options.frameY);
	end
end

function Accountant_FrameSavePosition()
	local left, top = AccountantFrame:GetLeft(), AccountantFrame:GetTop();
	local parentLeft, parentTop = UIParent:GetLeft(), UIParent:GetTop();
	if not left or not top or not parentLeft or not parentTop then return; end
	local x, y = left - parentLeft, top - parentTop;
	local options = Accountant_SaveData[Accountant_Server][Accountant_Player].options;
	options.frameX = x;
	options.frameY = y;
	AccountantFrame:ClearAllPoints();
	AccountantFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y);
end

function Accountant_WeekStart()
	local dt = date("*t");
	local weekstart = Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].weekstart;
	dt.day = dt.day - ((dt.wday - weekstart + 7) % 7);
	dt.hour = 12;
	dt.min = 0;
	dt.sec = 0;
	local ct = time(dt);
	return date("%Y-%m-%d", ct), string.sub(date(nil, ct), 1, 8);
end

function Accountant_CheckPeriods(forceWeek)
	local profile = Accountant_SaveData[Accountant_Server][Accountant_Player];
	local options = profile.options;
	local cdate = date("%Y-%m-%d");
	if options.date == cdate and not forceWeek then return; end

	local oldDate = string.sub(date(), 1, 8);
	if options.date ~= cdate and options.date ~= oldDate then
		for mode in pairs(Accountant_Data) do
			Accountant_Data[mode].Day.In = 0;
			Accountant_Data[mode].Day.Out = 0;
			profile.data[mode].Day.In = 0;
			profile.data[mode].Day.Out = 0;
		end
	end
	options.date = cdate;

	local weekDate, oldWeekDate = Accountant_WeekStart();
	if options.dateweek ~= weekDate and options.dateweek ~= oldWeekDate then
		for mode in pairs(Accountant_Data) do
			Accountant_Data[mode].Week.In = 0;
			Accountant_Data[mode].Week.Out = 0;
			profile.data[mode].Week.In = 0;
			profile.data[mode].Week.Out = 0;
		end
	end
	options.dateweek = weekDate;

	local monthDate = date("%Y-%m");
	if options.datemonth ~= monthDate then
		for mode in pairs(Accountant_Data) do
			Accountant_Data[mode].Month.In = 0;
			Accountant_Data[mode].Month.Out = 0;
			profile.data[mode].Month.In = 0;
			profile.data[mode].Month.Out = 0;
		end
	end
	options.datemonth = monthDate;

	local yearDate = date("%Y");
	if options.dateyear ~= yearDate then
		for mode in pairs(Accountant_Data) do
			Accountant_Data[mode].Year.In = 0;
			Accountant_Data[mode].Year.Out = 0;
			profile.data[mode].Year.In = 0;
			profile.data[mode].Year.Out = 0;
		end
	end
	options.dateyear = yearDate;
end

function Accountant_OnShow()
	Accountant_CheckPeriods();

	Accountant_SetLabels();
	if Accountant_CurrentTab ~= 5 then
		local TotalIn = 0;
		local TotalOut = 0;
		local mode = Accountant_LogModes[Accountant_CurrentTab];
		for key,value in pairs(Accountant_Data) do
			local row = _G["AccountantFrameRow"..Accountant_Data[key].InPos.."In"];
			row:SetText(Accountant_NiceCash(Accountant_Data[key][mode].In));
			TotalIn = TotalIn + Accountant_Data[key][mode].In;
			row = _G["AccountantFrameRow"..Accountant_Data[key].InPos.."Out"];
			TotalOut = TotalOut + Accountant_Data[key][mode].Out;
			row:SetText(Accountant_NiceCash(Accountant_Data[key][mode].Out));
		end

		AccountantFrameTotalInValue:SetText(Accountant_NiceCash(TotalIn));
		AccountantFrameTotalOutValue:SetText(Accountant_NiceCash(TotalOut));
		if TotalOut > TotalIn then
			local diff = TotalOut-TotalIn;
			AccountantFrameTotalFlow:SetText("|cFFFF3333"..ACCLOC_NETLOSS..":");
			AccountantFrameTotalFlowValue:SetText(Accountant_NiceCash(diff));
		else
			if TotalOut ~= TotalIn then
				local diff = TotalIn-TotalOut;
				AccountantFrameTotalFlow:SetText("|cFF00FF00"..ACCLOC_NETPROF..":");
				AccountantFrameTotalFlowValue:SetText(Accountant_NiceCash(diff));
			else
				AccountantFrameTotalFlow:SetText(ACCLOC_NET);
				AccountantFrameTotalFlowValue:SetText("");
			end
		end
	else
		-- character totals
		local alltotal = 0;
		local characters = {};
		for char,charvalue in pairs(Accountant_SaveData[Accountant_Server]) do
			local options = type(charvalue) == "table" and charvalue.options;
			if options and type(options.totalcash) == "number" then
				alltotal = alltotal + options.totalcash;
			end
			characters[#characters + 1] = char;
		end
		table.sort(characters);
		for i = 1, math.min(#characters, 15) do
			local char = characters[i];
			local charvalue = Accountant_SaveData[Accountant_Server][char];
			local options = type(charvalue) == "table" and charvalue.options;
			_G["AccountantFrameRow" ..i.."Title"]:SetText(char);
			if options and type(options.totalcash) == "number" then
				_G["AccountantFrameRow" ..i.."In"]:SetText(Accountant_NiceCash(options.totalcash));
				_G["AccountantFrameRow" ..i.."Out"]:SetText(options.date or "");
			else
				_G["AccountantFrameRow" ..i.."In"]:SetText("Unknown");
			end
		end
		AccountantFrameTotalInValue:SetText(Accountant_NiceCash(alltotal));

	end
	SetPortraitTexture(AccountantFramePortrait, "player");

	if Accountant_CurrentTab == 3 then
		AccountantFrameExtra:SetText(ACCLOC_WEEKSTART..":");
		AccountantFrameExtraValue:SetText(Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"]);
	elseif Accountant_CurrentTab == 6 then
		AccountantFrameExtra:SetText(ACCLOC_MONTH..":");
		AccountantFrameExtraValue:SetText(Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].datemonth);
	elseif Accountant_CurrentTab == 7 then
		AccountantFrameExtra:SetText(ACCLOC_YEAR..":");
		AccountantFrameExtraValue:SetText(Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].dateyear);
	else
		AccountantFrameExtra:SetText("");
		AccountantFrameExtraValue:SetText("");
	end

	PanelTemplates_SetTab(AccountantFrame, Accountant_CurrentTab);

end

function Accountant_OnHide(self)
	if MYADDONS_ACTIVE_OPTIONSFRAME == self then
		ShowUIPanel(myAddOnsFrame);
	end
end

function ACC_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function Accountant_ShowUsage()
	ACC_Print("/accountant log\n");
end

function Accountant_ResetData()
	local type = Accountant_LogModes[Accountant_CurrentTab];
	if type == "Total" then
		type = ACCLOC_TOTAL;
	elseif type == "Session" then
		type = ACCLOC_SESS;
	elseif type == "Day" then
		type = ACCLOC_DAY;
	elseif type == "Week" then
		type = ACCLOC_WEEK;
	elseif type == "Month" then
		type = ACCLOC_MONTH;
	elseif type == "Year" then
		type = ACCLOC_YEAR;
	else

	end

	StaticPopupDialogs["ACCOUNTANT_RESET"].text = ACCLOC_RESET_CONF.."\""..type.."\"?";
	local dialog = StaticPopup_Show("ACCOUNTANT_RESET","weeee");
end

function Accountant_ResetConfirmed()
	local type = Accountant_LogModes[Accountant_CurrentTab];
	for key,value in pairs(Accountant_Data) do
		Accountant_Data[key][type].In = 0;
		Accountant_Data[key][type].Out = 0;
		Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][type].In = 0;
		Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][type].Out = 0;
	end
	if AccountantFrame:IsVisible() then
		Accountant_OnShow();
	end
end

function Accountant_UpdateLog(currentMoney)
	Accountant_CheckPeriods();
	Accountant_CurrentMoney = currentMoney or GetMoney();
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].totalcash = Accountant_CurrentMoney;
	Accountant_MoneyInfoUpdate();
	local diff = Accountant_CurrentMoney - Accountant_LastMoney;
	Accountant_LastMoney = Accountant_CurrentMoney;
	if diff == 0 or diff == nil then
		return;
	end
	Accountant_LastMoneyDiff = diff;
	Accountant_LastMoneyChange = GetTime();

	local mode = Accountant_Mode;
	if mode == "" then mode = "OTHER"; end
	if diff >0 then
		for key,logmode in pairs(Accountant_LogModes) do
			Accountant_Data[mode][logmode].In = Accountant_Data[mode][logmode].In + diff
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode][logmode].In = Accountant_Data[mode][logmode].In;
		end
		if Accountant_Verbose then ACC_Print("Gained "..Accountant_NiceCash(diff).." from "..mode); end
	elseif diff < 0 then
		diff = diff * -1;
		for key,logmode in pairs(Accountant_LogModes) do
			Accountant_Data[mode][logmode].Out = Accountant_Data[mode][logmode].Out + diff
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode][logmode].Out = Accountant_Data[mode][logmode].Out;
		end
		if Accountant_Verbose then ACC_Print("Lost "..Accountant_NiceCash(diff).." from "..mode); end
	end

	-- special case mode resets
	if Accountant_Mode == "REPAIRS" then
		Accountant_Mode = "MERCH";
	end


	if AccountantFrame:IsVisible() then
		Accountant_OnShow();
	end
end

function AccountantTab_OnClick(self)
	PanelTemplates_SetTab(AccountantFrame, self:GetID());
	Accountant_CurrentTab = self:GetID();
	PlaySound("igCharacterInfoTab");
	Accountant_OnShow();
end

-- hooks

function Accountant_RepairAllItems(guildBankRepair)
	if (not guildBankRepair) then
		Accountant_Mode = "REPAIRS";
	end
	Accountant_RepairAllItems_old(guildBankRepair);
end

function Accountant_CursorHasItem()
	if InRepairMode() then
		Accountant_Mode = "REPAIRS";
	end
	local toret = Accountant_CursorHasItem_old();
	return toret;
end
