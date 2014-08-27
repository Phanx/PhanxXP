--[[--------------------------------------------------------------------
	PhanxXP
	A very simple XP and reputation bar. Based on jExp, by Mertex.
	Copyright (c) 2009-2014 Phanx. All rights reserved.
	See the accompanying LICENSE file for permissions and restrictions.
----------------------------------------------------------------------]]

local BAR_TEXTURE = select(6, GetAddOnInfo("PhanxMedia")) ~= "MISSING"
	and [[Interface\AddOns\PhanxMedia\statusbar\HalA]]
	or [[Interface\TargetingFrame\UI-StatusBar]]

local XP_COLOR   = { r = 0.4, g = 0,   b = 0.8 } -- 0.2, 0, 0.5
local REST_COLOR = { r = 0,   g = 0.5, b = 1 } -- 0, 0.25, 0.6

------------------------------------------------------------------------

local f = CreateFrame("Frame", "PhanxXP", UIParent)
f:SetFrameStrata("HIGH") -- "LOW"
f:SetHeight(5) -- 35
f:SetPoint("BOTTOMLEFT", UIParent)
f:SetPoint("BOTTOMRIGHT", UIParent)

local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetTexture(BAR_TEXTURE)
bg:SetVertexColor(0.1, 0.1, 0.1)
bg:SetPoint("BOTTOMLEFT")
bg:SetPoint("BOTTOMRIGHT")
bg:SetPoint("TOP", 0, 1)
f.bg = bg

local rest = CreateFrame("StatusBar", nil, f)
rest:SetStatusBarTexture(BAR_TEXTURE)
rest:SetStatusBarColor(REST_COLOR.r, REST_COLOR.g, REST_COLOR.b / 2)
rest:SetPoint("BOTTOMLEFT")
rest:SetPoint("BOTTOMRIGHT")
rest:SetPoint("TOP")
f.rest = rest

local bar = CreateFrame("StatusBar", nil, rest)
bar:SetStatusBarTexture(BAR_TEXTURE)
bar:SetStatusBarColor(XP_COLOR.r, XP_COLOR.g, XP_COLOR.b)
bar:SetPoint("BOTTOMLEFT")
bar:SetPoint("BOTTOMRIGHT")
bar:SetPoint("TOP")
f.bar = bar
--[[
local shadow = bar:CreateTexture(nil, "BACKGROUND")
shadow:SetTexture("Interface\\AddOns\\PhanxBorder\\Shadow")
shadow:SetTexCoord(1/3, 2/3, 0, 1/3)
shadow:SetVertexColor(0, 0, 0)
shadow:SetPoint("LEFT", f, "TOPLEFT", 0, -5)
shadow:SetPoint("RIGHT", f, "TOPRIGHT", 0, -5)
shadow:SetHeight(21)
f.shadow = shadow

local border = bar:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\AddOns\\PhanxBorder\\Border")
border:SetTexCoord(1/3, 2/3, 0, 1/3)
border:SetVertexColor(0.5, 0.5, 0.5)
border:SetPoint("TOPLEFT", 0, -4)
border:SetPoint("TOPRIGHT", 0, -4)
border:SetHeight(12)
f.border = border

function f:SetBorderColor(r, g, b)
	border:SetVertexColor(r, g, b)
end

function f:SetBorderSize(size)
	border:SetHeight(size)
end
]]
------------------------------------------------------------------------

function f:ShowXP()
	local cur, max, rcur = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()

	bar:SetStatusBarColor(XP_COLOR.r, XP_COLOR.g, XP_COLOR.b)
	bar:SetMinMaxValues(0, max)
	bar:SetValue(cur)

	if rcur then
		rest:SetMinMaxValues(0, max)
		if cur + rcur > max then
			rest:SetValue(max)
		else
			rest:SetValue(cur + rcur)
		end
	else
		rest:SetMinMaxValues(0, 1)
		rest:SetValue(0)
	end

	f.showing = "XP"
end

function f:ShowRep()
	local name, standing, min, max, cur = GetWatchedFactionInfo()
	if not name then
		return self:ShowXP()
	end

	bar:SetStatusBarColor(FACTION_BAR_COLORS[ standing ].r * 0.8, FACTION_BAR_COLORS[ standing ].g * 0.8, FACTION_BAR_COLORS[ standing ].b * 0.8)
	bar:SetMinMaxValues(min, max)
	bar:SetValue(cur)

	rest:SetMinMaxValues(0, 1)
	rest:SetValue(0)

	f.showing = "FACTION"
end

local MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[ GetExpansionLevel() ]
function f:Update(event)
	if C_PetBattles.IsInBattle() then
		return f:Hide()
	end
	f:Show()
	if UnitLevel("player") == MAX_LEVEL or IsControlKeyDown() then
		f:ShowRep()
	else
		f:ShowXP()
	end
end

f:RegisterEvent("MODIFIER_STATE_CHANGED")
f:RegisterEvent("PET_BATTLE_OPENING_START")
f:RegisterEvent("PET_BATTLE_CLOSE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("UPDATE_EXHAUSTION")
f:RegisterEvent("UPDATE_FACTION")

f:SetScript("OnEvent", f.Update)
hooksecurefunc("SetWatchedFactionIndex", f.Update)
--[[
f:EnableMouse(true)

f:SetScript("OnEnter", function(self)

	local LDB = LibStub("LibDataBroker-1.1", true)
	if LDB then
		local Progress = LDB:GetDataObjectByName("Progress")
		if Progress then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			Progress.OnTooltipShow(GameTooltip)
			return GameTooltip:Show()
		end
	end

	local mxp = UnitXPMax("player")
	local xp = UnitXP("player")
	local rxp = GetXPExhaustion()
	local name, standing, minrep, maxrep, value = GetWatchedFactionInfo()

	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	GameTooltip:AddLine("jExp")
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		GameTooltip:AddDoubleLine(COMBAT_XP_GAIN, xp.."|cffffd100/|r"..mxp.." |cffffd100/|r "..floor((xp/mxp)*1000)/10 .."%",NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26, rxp .." |cffffd100/|r ".. floor((rxp/mxp)*1000)/10 .."%", NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
		end
		if name then
			GameTooltip:AddLine(" ")
		end
	end
	if name then
		GameTooltip:AddDoubleLine(FACTION, name, NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
		GameTooltip:AddDoubleLine(STANDING, getglobal("FACTION_STANDING_LABEL"..standing), NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b)
		GameTooltip:AddDoubleLine(REPUTATION, value-minrep .."|cffffd100/|r"..maxrep-minrep.." |cffffd100/|r "..floor((value-minrep)/(maxrep-minrep)*1000)/10 .."%", NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
	end

	GameTooltip:Show()
end)

f:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

f:SetScript("OnMouseDown", function(self, button)
	local LDB = LibStub("LibDataBroker-1.1", true)
	if LDB then
		local Progress = LDB:GetDataObjectByName("Progress")
		if Progress then
			return Progress.OnClick(self, button)
		end
	end
end)]]