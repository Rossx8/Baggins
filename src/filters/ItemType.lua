--[[ ==========================================================================

ItemType.lua

========================================================================== ]]--

local _G = _G

local AddOnName, _ = ...
local AddOn = _G[AddOnName]

-- LUA Functions
local pairs = _G.pairs
local tostring = _G.tostring
local tonumber = _G.tonumber

-- WoW API
local GetItemClassInfo = _G.GetItemClassInfo
local GetItemSubClassInfo = _G.GetItemSubClassInfo
local GetContainerItemID = _G.GetContainerItemID
local GetItemInfoInstant = _G.GetItemInfoInstant

--[===[@non-retail@
local GetAuctionItemSubClasses = _G.GetAuctionItemSubClasses
--@end-non-retail@]===]
--@retail@
local GetAuctionItemSubClasses = _G.C_AuctionHouse.GetAuctionItemSubClasses
--@end-retail@

-- Libs
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnName)

--@retail@
-- Baggins: AH category scanned 2020-05-20 3:40:00 - patch 8.3.0
local ItemTypes = {
    [0]="Consumable",
    [1]="Container",
    [2]="Weapon",
    [3]="Gem",
    [4]="Armor",
    [5]="Reagent",--won't use in classic --
    [6]="Projectile",
    [7]="Tradeskill",
    [8]="Item Enhancement",
    [9]="Recipe",
    [10]="Money(OBSOLETE)",
    [11]="Quiver",
    [12]="Quest",
    [13]="Key",
    [14]="Permanent(OBSOLETE)",
    [15]="Miscellaneous",
    [16]="Glyph",--won't use in classic --
    [17]="Battle Pets",--won't use in classic --
    [18]="WoW Token"--won't use in classic --
}
--@end-retail@
--[===[@non-retail@
-- scanned Wed May 20 05:04:36 2020 - patch 1.13.4
local ItemTypes = {
    [0]="Consumable",
    [1]="Container",
    [2]="Weapon",
    [3]="Jewelry(OBSOLETE)",
    [4]="Armor",
    [5]="Reagent",
    [6]="Projectile",
    [7]="Trade Goods",
    [8]="Generic(OBSOLETE)",
    [9]="Recipe",
    [10]="Money(OBSOLETE)",
    [11]="Quiver",
    [12]="Quest",
    [13]="Key",
    [14]="Permanent(OBSOLETE)",
    [15]="Miscellaneous",
    [18]="WoW Token"
}
--@end-non-retail@]===]

  --[[
  local ItemTypes = {
   ["Weapon"] = {"One-Handed Axes", "Two-Handed Axes", "Bows", "Guns", "One-Handed Maces", "Two-Handed Maces", "Polearms", "One-Handed Swords", "Two-Handed Swords", "Staves", "Fist Weapons", "Miscellaneous", "Daggers", "Thrown", "Crossbows", "Wands", "Fishing Poles"},
   ["Armor"] = {"Miscellaneous", "Cloth", "Leather", "Mail", "Plate", "Cosmetic", "Shields"},
   ["Container"] = {"Bag", "Herb Bag", "Enchanting Bag", "Engineering Bag", "Gem Bag", "Mining Bag", "Leatherworking Bag", "Inscription Bag", "Tackle Box", "Cooking Bag"},
   ["Gem"] = {"Red", "Blue", "Yellow", "Purple", "Green", "Orange", "Meta", "Simple", "Prismatic", "Cogwheel"},
   ["Consumable"] = {"Food & Drink", "Potion", "Elixir", "Flask", "Bandage", "Item Enhancement", "Scroll", "Other"},
   ["Glyph"] = {"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Death Knight", "Shaman", "Mage", "Warlock", "Monk", "Druid"},
   ["Item Enhancement"] = {},
   ["Trade Goods"] = {"Elemental", "Cloth", "Leather", "Metal & Stone", "Cooking", "Herb", "Enchanting", "Jewelcrafting", "Parts", "Devices", "Explosives", "Materials", "Other", "Item Enchantment"},
   ["Quest"] = {},
   ["Recipe"] = {"Book", "Leatherworking", "Tailoring", "Engineering", "Blacksmithing", "Cooking", "Alchemy", "First Aid", "Enchanting", "Fishing", "Jewelcrafting", "Inscription"},
   ["Miscellaneous"] = {"Junk", "Reagent", "Companion Pets", "Holiday", "Other", "Mount"},
   ["Battle Pets"] = {"Humanoid", "Dragonkin", "Flying", "Undead", "Critter", "Magic", "Elemental", "Beast", "Aquatic", "Mechanical"},
  }--]]


  -- Old Scan Method
  --[[
  SELECTED_CHAT_FRAME:AddMessage("--------------------------")
  SELECTED_CHAT_FRAME:AddMessage("-- scanned "..date("%c").. " - patch "..(GetBuildInfo()))
  SELECTED_CHAT_FRAME:AddMessage("local ItemTypes = {")
  for i,class in pairs{GetAuctionItemClasses()} do
    local subs={GetAuctionItemSubClasses(i)}
    if #subs>0 then

      SELECTED_CHAT_FRAME:AddMessage('  ["'..class..'"] = {"'..
        table.concat(subs, '", "') ..
      '"},')
    else
      SELECTED_CHAT_FRAME:AddMessage('  ["'..class..'"] = {},')
    end
  end
  SELECTED_CHAT_FRAME:AddMessage("}")
  --]]
--New Retail Scan
--print("--------------------------")
--print("-- scanned "..date("%c").. " - patch "..(GetBuildInfo()))
--for i = 0, NUM_LE_ITEM_CLASSS-1 do
--	print(i, GetItemClassInfo(i))
--end

local function Matches(bag,slot,rule)
    if not (rule.itype or rule.isubtype) then return end
    local itemid = GetContainerItemID(bag, slot)
    if itemid then
        local _, _, _, _, _, TypeID, SubTypeID = GetItemInfoInstant(itemid)
        if TypeID and SubTypeID then
            return TypeID == rule.itype and (rule.isubtype == nil or SubTypeID == rule.isubtype )
        end
    end
end

local function GetName(rule)
    local ltype, lsubtype = "*", "*"
    if rule.itype then
        ltype = GetItemClassInfo(rule.itype) or "?"
    end
    if rule.isubtype then
        lsubtype = GetItemSubClassInfo(rule.itype, rule.isubtype) or "?"
    end
    return L["ItemType - "]..ltype..":"..lsubtype
end

AddOn:AddCustomRule("ItemType",
    {
        DisplayName = L["Item Type"],
        Description = L["Filter by Item type and sub-type as returned by GetItemInfo"],
        Matches = Matches,
        GetName = GetName,
        Ace3Options = {
            itype = {
                type = 'select',
                name = L["Item Type"],
                desc = "",
                values = function(info) --luacheck: ignore 212
                        local tmp = {}
                        for i in pairs(ItemTypes) do
                            tmp[i] = GetItemClassInfo(i)
                        end
                        return tmp
                    end,
                order = 10,
            },
            isubtype = {
                name = L["Item Subtype"],
                desc = "",
                type = "select",
                get = function(info)
                        return tostring(info.arg.isubtype or "ALL")
                    end,
                set = function(info, value)
                        local rule = info.arg
                        if value == "ALL" then
                            rule.isubtype = nil
                        else
                            rule.isubtype = tonumber(value)
                        end
                        AddOn:OnRuleChanged()
                    end,
                values = function(info)
                        local rule = info.arg
                        local tmp = {}
                        tmp.ALL = _G.ALL
                        if rule.itype and ItemTypes[rule.itype] then
                            --[===[@non-retail@
                            for _,k in pairs({GetAuctionItemSubClasses(rule.itype)}) do
                            --@end-non-retail@]===]
                            --@retail@
                            for _,k in pairs(GetAuctionItemSubClasses(rule.itype)) do
                            --@end-retail@
                                tmp[tostring(k)] = GetItemSubClassInfo(rule.itype, k) or UNKNOWN
                            end
                        end
                        return tmp
                    end,
                order = 20,
            }
        },
        CleanRule = function(rule)
            rule.itype="Miscellaneous"
        end
    }
)