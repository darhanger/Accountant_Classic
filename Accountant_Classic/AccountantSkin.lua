local E = ElvUI and ElvUI[1];
if not E then return; end

local S = E:GetModule("Skins");

local function Accountant_SkinLine(frame, x1, y1, x2, y2)
	local line = frame:CreateTexture(nil, "BORDER");
	line:SetTexture(E.media.blankTex);
	line:SetVertexColor(0.35, 0.35, 0.35, 0.5);
	line:SetPoint("TOPLEFT", frame, "TOPLEFT", x1, y1);
	line:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", x2, y2);
end

local function Accountant_SkinElvUI()
	local frame = AccountantFrame;
	frame:SetTemplate("Transparent");
	AccountantFrameTopLeft:SetTexture(nil);
	AccountantFrameTopRight:SetTexture(nil);
	AccountantFrameBotLeft:SetTexture(nil);
	AccountantFrameBotRight:SetTexture(nil);

	local tableBackground = frame:CreateTexture(nil, "BACKGROUND");
	tableBackground:SetTexture(E.media.blankTex);
	tableBackground:SetVertexColor(0, 0, 0, 0.2);
	tableBackground:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -87);
	tableBackground:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -10, -411);

	local header = frame:CreateTexture(nil, "BORDER");
	header:SetTexture(E.media.blankTex);
	header:SetVertexColor(1, 1, 1, 0.06);
	header:SetPoint("TOPLEFT", frame, "TOPLEFT", 21, -88);
	header:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -10, -110);

	Accountant_SkinLine(frame, 196, -87, 197, -411);
	Accountant_SkinLine(frame, 354, -87, 355, -411);
	for i = 0, 15 do
		local y = -110 - i * 20;
		Accountant_SkinLine(frame, 20, y, 502, y - 1);
	end

	AccountantFramePortrait:SetSize(42, 42);
	AccountantFramePortrait:ClearAllPoints();
	AccountantFramePortrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -10);
	AccountantFramePortrait:SetTexCoord(0.15, 0.85, 0.15, 0.85);
	AccountantFramePortrait:CreateBackdrop("Default");
	AccountantFrameTitleText:FontTemplate(nil, 12);
	AccountantFrameSource:FontTemplate(nil, 11);
	AccountantFrameIn:FontTemplate(nil, 11);
	AccountantFrameOut:FontTemplate(nil, 11);
	AccountantFrameTotalIn:FontTemplate(nil, 11);
	AccountantFrameTotalInValue:FontTemplate(nil, 11);
	AccountantFrameTotalOut:FontTemplate(nil, 11);
	AccountantFrameTotalOutValue:FontTemplate(nil, 11);
	AccountantFrameTotalFlow:FontTemplate(nil, 11);
	AccountantFrameTotalFlowValue:FontTemplate(nil, 11);
	AccountantFrameExtra:FontTemplate(nil, 11);
	AccountantFrameExtraValue:FontTemplate(nil, 11);

	for i = 1, 15 do
		local row = _G["AccountantFrameRow"..i];
		if i % 2 == 0 then
			local stripe = row:CreateTexture(nil, "BACKGROUND");
			stripe:SetAllPoints(row);
			stripe:SetTexture(E.media.blankTex);
			stripe:SetVertexColor(1, 1, 1, 0.04);
		end
		_G["AccountantFrameRow"..i.."Title"]:FontTemplate(nil, 11);
		_G["AccountantFrameRow"..i.."In"]:FontTemplate(nil, 11);
		_G["AccountantFrameRow"..i.."Out"]:FontTemplate(nil, 11);
	end

	S:HandleCloseButton(AccountantFrameCloseButton);
	S:HandleButton(AccountantFrameOptionsButton);
	S:HandleButton(AccountantFrameExitButton);
	S:HandleButton(AccountantFrameResetButton);
	for i = 1, 7 do
		S:HandleTab(_G["AccountantFrameTab"..i]);
	end

	AccountantMoneyInfoFrame:SetTemplate("Transparent");
	AccountantMoneyInfoFrameText:FontTemplate(nil, 11);

	AccountantOptionsFrame:SetTemplate("Transparent");
	if AccountantOptionsFrame.aboutFrame then
		AccountantOptionsFrame.aboutFrame:SetTemplate("Transparent");
	end
	AccountantOptionsFrameTitleText:FontTemplate(nil, 12);
	S:HandleCheckBox(AccountantOptionsFrameToggleButton);
	S:HandleCheckBox(AccountantOptionsFrameMoneyInfoButton);
	S:HandleCheckBox(AccountantOptionsFrameMoneyIconsButton);
	AccountantOptionsFrameToggleButtonText:FontTemplate(nil, 11);
	AccountantOptionsFrameMoneyInfoButtonText:FontTemplate(nil, 11);
	AccountantOptionsFrameMoneyIconsButtonText:FontTemplate(nil, 11);
	S:HandleDropDownBox(AccountantOptionsFrameWeek, 150);
	AccountantOptionsFrameWeekLabel:FontTemplate(nil, 11);
	S:HandleButton(AccountantOptionsFrameDone);
end

if S.Initialized then
	Accountant_SkinElvUI();
else
	S:AddCallbackForAddon("Accountant_Classic", "AccountantClassicSkin", Accountant_SkinElvUI);
end
