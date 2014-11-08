--[[--------------------------------------------------------------------
	PhanxXP
	A very simple XP and reputation bar.
	Inspired by jExp, by Mertex.
	Copyright (c) 2009-2014 Phanx <addons@phanx.net>. All rights reserved.

	Please DO NOT upload this addon to other websites, or post modified
	versions of it. However, you are welcome to include a copy of it
	WITHOUT CHANGES in compilations posted on Curse and/or WoWInterface.
	You are also welcome to use any/all of its code in your own addon, as
	long as you do not use my name or the name of this addon ANYWHERE in
	your addon, including its name, outside of an optional attribution.
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
bg:SetPoint("BOTTOMLEFT")
bg:SetPoint("BOTTOMRIGHT")
bg:SetPoint("TOP", 0, 1)
bg:SetTexture(BAR_TEXTURE)
bg:SetVertexColor(0.1, 0.1, 0.1)
f.bg = bg

local rest = CreateFrame("StatusBar", nil, f)
rest:SetAllPoints(true)
rest:SetStatusBarTexture(BAR_TEXTURE)
rest:SetStatusBarColor(REST_COLOR.r, REST_COLOR.g, REST_COLOR.b / 2)
f.rest = rest

local bar = CreateFrame("StatusBar", nil, rest)
bar:SetAllPoints(true)
bar:SetStatusBarTexture(BAR_TEXTURE)
bar:SetStatusBarColor(XP_COLOR.r, XP_COLOR.g, XP_COLOR.b)
f.bar = bar

------------------------------------------------------------------------

local MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

function f:Update(event)
	if C_PetBattles.IsInBattle() then
		return f:Hide()
	end
	f:Show()

	if UnitLevel("player") == MAX_LEVEL or IsControlKeyDown() then
		local name, standing, min, max, cur = GetWatchedFactionInfo()
		if name then
			local color = FACTION_BAR_COLORS[standing]
			bar:SetStatusBarColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
			bar:SetMinMaxValues(min, max)
			bar:SetValue(cur)
			rest:SetMinMaxValues(0, 1)
			rest:SetValue(0)
			return
		end
	end

	local cur, max, plus = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	bar:SetStatusBarColor(XP_COLOR.r, XP_COLOR.g, XP_COLOR.b)
	bar:SetMinMaxValues(0, max)
	bar:SetValue(cur)
	if plus then
		rest:SetMinMaxValues(0, max)
		if cur + plus > max then
			rest:SetValue(max)
		else
			rest:SetValue(cur + plus)
		end
	else
		rest:SetMinMaxValues(0, 1)
		rest:SetValue(0)
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