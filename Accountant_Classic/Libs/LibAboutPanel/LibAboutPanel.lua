local lib, oldminor = LibStub:NewLibrary("LibAboutPanel", 4)
if not lib then return end

local L = {
	["About"] = "About",
	["Author"] = "Author",
	["Category"] = "Category",
	["Credits"] = "Credits",
	["Donate"] = "Donate",
	["Email"] = "Email",
	["License"] = "License",
	["Localizations"] = "Translations",
	["Version"] = "Version",
	["Website"] = "Website",
	["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy.",
	["on"] = "on",
}

local GAME_LOCALE = GetLocale()
if GAME_LOCALE == "frFR" then
	L["About"] = "à propos de"
	L["Localizations"] = "Traductions"
elseif GAME_LOCALE == "deDE" then
	L["About"] = "Über"
	L["Author"] = "Autor"
	L["Category"] = "Kategorie"
	L["Credits"] = "Ehren"
	L["Donate"] = "Spenden"
	L["Email"] = "E-Mail"
	L["License"] = "Lizenz"
	L["Localizations"] = "Übersetzungen"
	L["Version"] = "Version"
	L["Website"] = "Webseite"
	L["Click and press Ctrl-C to copy"] = "Klicken und Strg-C drücken zum kopieren."
	L["on"] = "von"
elseif GAME_LOCALE == "esES" or GAME_LOCALE == "esMX" then
	L["About"] = "Sobre"
	L["Author"] = "Autor"
	L["Category"] = "Categoría"
	L["Credits"] = "Créditos"
	L["Donate"] = "Donar"
	L["Email"] = "Email"
	L["License"] = "Licencia"
	L["Localizations"] = "Idiomas"
	L["Version"] = "Versión"
	L["Website"] = "Sitio web"
	L["Click and press Ctrl-C to copy"] = "Clic y pulse Ctrl-C para copiar."
	L["on"] = "de"
elseif GAME_LOCALE == "koKR" then
	L["About"] = "대하여"
	L["Localizations"] = "번역"
	L["Click and press Ctrl-C to copy"] = "클릭 후 Ctrl-C 복사"
elseif GAME_LOCALE == "ruRU" then
	L["About"] = "Об аддоне"
	L["Localizations"] = "Переводы"
elseif GAME_LOCALE == "zhCN" then
	L["About"] = "关于"
	L["Localizations"] = "翻译"
	L["Click and press Ctrl-C to copy"] = "点击并 Ctrl-C 复制"
elseif GAME_LOCALE == "zhTW" then
	L["About"] = "關於"
	L["Localizations"] = "翻譯"
	L["Click and press Ctrl-C to copy"] = "左鍵點擊並按下 Ctrl-C 以複製字串"
end

function lib.new(parent, addonname, categoryName)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame.name, frame.parent, frame.addonname = parent and L["About"] or (categoryName or gsub(addonname," ","")), parent, gsub(addonname," ","") -- Remove spaces from addonname because GetMetadata doesn't like that
	frame:Hide()
	frame:SetScript("OnShow", lib.OnShow)
	InterfaceOptions_AddCategory(frame)
	return frame
end

local editbox = CreateFrame("EditBox", nil, UIParent)
editbox:Hide()
editbox:SetAutoFocus(true)
editbox:SetHeight(32)
editbox:SetFontObject("GameFontHighlightSmall")
lib.editbox = editbox

local left = editbox:CreateTexture(nil, "BACKGROUND")
left:SetWidth(8) left:SetHeight(20)
left:SetPoint("LEFT", -5, 0)
left:SetTexture("Interface\\Common\\Common-Input-Border")
left:SetTexCoord(0, 0.0625, 0, 0.625)

local right = editbox:CreateTexture(nil, "BACKGROUND")
right:SetWidth(8) right:SetHeight(20)
right:SetPoint("RIGHT", 0, 0)
right:SetTexture("Interface\\Common\\Common-Input-Border")
right:SetTexCoord(0.9375, 1, 0, 0.625)

local center = editbox:CreateTexture(nil, "BACKGROUND")
center:SetHeight(20)
center:SetPoint("RIGHT", right, "LEFT", 0, 0)
center:SetPoint("LEFT", left, "RIGHT", 0, 0)
center:SetTexture("Interface\\Common\\Common-Input-Border")
center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
editbox:SetScript("OnEnterPressed", editbox.ClearFocus)
editbox:SetScript("OnEditFocusLost", editbox.Hide)
editbox:SetScript("OnEditFocusGained", editbox.HighlightText)
editbox:SetScript("OnTextChanged", function(self)
	self:SetText(self:GetParent().val)
	self:HighlightText()
end)


function lib.OpenEditbox(self)
	editbox:SetText(self.val)
	editbox:SetParent(self)
	editbox:SetPoint("LEFT", self)
	editbox:SetPoint("RIGHT", self)
	editbox:Show()
end


local fields = {"Version", "Author", "X-Category", "X-License", "X-Email", "Email", "eMail", "X-Website", "X-Credits", "X-Localizations", "X-Donate"}
local localizationNames = {
	enUS = "English", frFR = "French", deDE = "German",
	zhCN = "Simplified Chinese", zhTW = "Traditional Chinese", koKR = "Korean", ruRU = "Russian",
}
if GAME_LOCALE == "ruRU" then
	localizationNames.enUS = "Английский"
	localizationNames.frFR = "Французский"
	localizationNames.deDE = "Немецкий"
	localizationNames.zhCN = "Упрощённый китайский"
	localizationNames.zhTW = "Традиционный китайский"
	localizationNames.koKR = "Корейский"
	localizationNames.ruRU = "Русский"
end
local haseditbox = {["X-Website"] = true, ["X-Email"] = true, ["X-Donate"] = true, ["Email"] = true, ["eMail"] = true}
local fieldLabels = {["eMail"] = "Email"}

local function HideTooltip() GameTooltip:Hide() end

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:SetText(L["Click and press Ctrl-C to copy"])
end

function lib.OnShow(frame)
	local notefield = "Notes"
	if GAME_LOCALE ~= "enUS" then
		notefield = notefield .. "-" .. GAME_LOCALE
	end

	-- Get the localized version of notes if it exists or fall back to the english one.
	local notes = GetAddOnMetadata(frame.addonname, notefield) or GetAddOnMetadata(frame.addonname, "Notes")

	local title = frame.about_title
	if not title then
		title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		frame.about_title = title
	end
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText((frame.parent or frame.name) .. " - " .. L["About"])

	if not frame.about_subtitle then
		frame.about_subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	end

	local subtitle = frame.about_subtitle
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", frame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(notes)

	local anchor
	for i = 1, #fields do
		local field = fields[i]
		local val = GetAddOnMetadata(frame.addonname, field)
		if val then
			local title = frame[field .. "_title"]
			if not title then
				title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
				frame[field .. "_title"] = title
			end
			if field == "X-Localizations" then
				title:SetWidth(300)
				title:SetPoint("TOPLEFT", anchor or subtitle, "BOTTOMLEFT", anchor and 6 or 4, -24)
				title:SetJustifyH("LEFT")
			elseif not anchor then
				title:SetWidth(80)
				title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -12)
				title:SetJustifyH("RIGHT")
			else
				title:SetWidth(80)
				title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
				title:SetJustifyH("RIGHT")
			end
			title:SetJustifyV("TOP")
			title:SetText(L[fieldLabels[field] or field:gsub("X%-", "")] .. (field == "X-Localizations" and ":" or ""))

			local detail = frame[field .. "_detail"]
			if not detail then
				detail = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
				frame[field .. "_detail"] = detail
			end
			if field == "X-Localizations" then
				detail:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
			else
				detail:SetPoint("TOPLEFT", title, "TOPRIGHT", 4, 0)
			end
			detail:SetPoint("RIGHT", frame, -16, 0)
			detail:SetJustifyH("LEFT")
			detail:SetJustifyV("TOP")

			if field == "Author" then
				local authorservername = GetAddOnMetadata(frame.addonname, "X-Author-Server")
				local authorfaction = GetAddOnMetadata(frame.addonname, "X-Author-Faction")
				if authorservername and authorfaction then
					detail:SetText(val .. " " .. L["on"] .. " " .. authorservername .. " (" .. authorfaction .. ")")
				elseif authorservername and not authorfaction then
					detail:SetText(val .. " " .. L["on"] .. " " .. authorservername)
				elseif not authorservername and authorfaction then
					detail:SetText(val .. " (" .. authorfaction .. ")")
				else
					detail:SetText(val)
				end
			elseif field == "Version" then
				local addonversion = GetAddOnMetadata(frame.addonname, field)
				-- Remove @project-revision@ and replace it with Repository
				addonversion = string.gsub(addonversion,"@project.revision@","Repository") -- Curse
				addonversion = string.gsub(addonversion,"wowi:revision","Repository") -- WoWInterface
				detail:SetText(addonversion)
			elseif field == "X-License" then
				local copyright = GetAddOnMetadata(frame.addonname, "X-Copyright")
				if copyright then
					detail:SetText(copyright .. "\n" .. val)
				else
					detail:SetText(val)
				end
			elseif field == "X-Website" then
				detail:SetText((haseditbox[field] and "|cff77ccff" or "") .. gsub(val, "^https?://", ""))
			elseif field == "X-Localizations" then
				local languages = {}
				for code in string.gmatch(val, "[^,%s]+") do
					languages[#languages + 1] = (localizationNames[code] or code) .. " (" .. code .. ")"
				end
				detail:SetText(table.concat(languages, "\n"))
			else
				detail:SetText((haseditbox[field] and "|cff77ccff" or "") .. val)
			end

			local lineheight = field == "X-Localizations" and detail:GetStringHeight() or math.min(detail:GetStringHeight(), 32)
			title:SetHeight(field == "X-Localizations" and 16 or lineheight)
			detail:SetHeight(lineheight)

			if haseditbox[field] then
				local button = frame[field .. "_button"]
				if not button then
					button = CreateFrame("Button", nil, frame)
					frame[field .. "_button"] = button
					button:SetAllPoints(detail)
					button:SetScript("OnClick", lib.OpenEditbox)
					button:SetScript("OnEnter", ShowTooltip)
					button:SetScript("OnLeave", HideTooltip)
				end
				button.val = val
			end

			anchor = field == "X-Localizations" and detail or title
		end
	end
end
