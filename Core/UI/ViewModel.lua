local _, KeyMaster = ...
KeyMaster.ViewModel = {}
local ViewModel = KeyMaster.ViewModel
local CharacterInfo = KeyMaster.CharacterInfo
local DungeonTools = KeyMaster.DungeonTools
local Theme = KeyMaster.Theme

local partyFrameLookup = {
    ["player"] = "KM_PlayerRow1",
    ["party1"] = "KM_PlayerRow2",
    ["party2"] = "KM_PlayerRow3",
    ["party3"] = "KM_PlayerRow4",
    ["party4"] = "KM_PlayerRow5"
}

function ViewModel:ShowPartyRow(unitId)
    _G[partyFrameLookup[unitId]]:Show()    
end

function ViewModel:HidePartyRow(unitId)
    _G[partyFrameLookup[unitId]]:Hide()
end

function ViewModel:HideAllPartyFrame()
    for i=1,4,1 do
        _G[partyFrameLookup["party"..i]]:Hide()
    end
end

-- Party member data assign
function ViewModel:UpdateUnitFrameData(unitId, playerData)
    if(unitId == nil) then 
        print("ERROR: parameter unitId in function UpdateUnitFrameData cannot be empty.")
        return
    end

    --local playerData = UnitData:GetUnitDataByUnitId(unitId)
    if(playerData == nil) then 
        print("ERROR: 'playerData' in function UpdateUnitFrameData cannot be empty.")
        return
    end

    local partyPlayer
    if (unitId == "player") then
        partyPlayer = 1
    elseif (unitId == "party1") then
        partyPlayer = 2
    elseif (unitId == "party2") then
        partyPlayer = 3
    elseif (unitId == "party3") then
        partyPlayer = 4
    elseif (unitId == "party4") then
        partyPlayer = 5
    end
    
    -- Set Player Portrait
    SetPortraitTexture(_G["KM_Portrait"..partyPlayer], unitId)
    
    -- Spec & Class
    local unitClassSpec
    local unitClass, _ = UnitClass(unitId)
    local unitSpecialization = CharacterInfo:GetPlayerSpecialization(unitId)
    if unitSpecialization ~= nil then
        unitClassSpec = unitSpecialization.." "..unitClass
    else
        unitClassSpec = unitClass
    end
    _G["KM_Player"..partyPlayer.."Class"]:SetText(unitClassSpec)
    
    -- Player Name
    _G["KM_PlayerName"..partyPlayer]:SetText("|cff"..CharacterInfo:GetMyClassColor(unitId)..playerData.name.."|r")

    -- Player Rating
    _G["KM_Player"..partyPlayer.."OverallRating"]:SetText(playerData.mythicPlusRating)

    if unitId == "player" then
        local myRatingColor = C_ChallengeMode.GetDungeonScoreRarityColor(playerData.mythicPlusRating) -- todo: cache this? but it is relevant to the client rating.
        _G["KeyMaster_RatingScore"]:SetTextColor(myRatingColor.r, myRatingColor.g, myRatingColor.b)
        _G["KeyMaster_RatingScore"]:SetText((playerData.mythicPlusRating)) -- todo: This doesn't belong here. Refreshes rating in header.    
    end

    -- Dungeon Key Information
    local ownedKeyLevel
    if (not playerData.ownedKeyLevel or playerData.ownedKeyLevel == 0) then
        ownedKeyLevel = ""
    else 
        ownedKeyLevel = "("..playerData.ownedKeyLevel..") "
    end
    _G["KM_OwnedKeyInfo"..partyPlayer]:SetText(ownedKeyLevel..DungeonTools:GetDungeonNameAbbr(playerData.ownedKeyId))

    -- Dungeon Scores
    if KeyMaster:GetTableLength(playerData.DungeonRuns) ~= 0 then
        local mapTable = DungeonTools:GetCurrentSeasonMaps()
        local r, g, b, colorWeekHex = Theme:GetWeekScoreColor()
        for n, v in pairs(mapTable) do
            -- TODO: Determine if the current week is Fortified or Tyrannical and ask for the relating data.
            _G["KM_MapLevelT"..partyPlayer..n]:SetText(playerData.DungeonRuns[n]["Tyrannical"].Level)
            --_G["KM_MapScoreT"..partyPlayer..n]:SetText("|cff"..colorWeekHex..playerData.DungeonRuns[n]["Tyrannical"].Score.."|r")
            _G["KM_MapLevelF"..partyPlayer..n]:SetText(playerData.DungeonRuns[n]["Fortified"].Level)
            --_G["KM_MapScoreF"..partyPlayer..n]:SetText("|cff"..colorWeekHex..playerData.DungeonRuns[n]["Fortified"].Score.."|r")
            _G["KM_MapTotalScore"..partyPlayer..n]:SetText(playerData.DungeonRuns[n]["bestOverall"])
        end
    else
        _G["KM_MapDataLegend"..partyPlayer]:Hide()
    end

    if (not playerData.hasAddon) then
        _G["KM_NoAddon"..partyPlayer]:Show()        
    else
        _G["KM_NoAddon"..partyPlayer]:Hide()
    end    
end