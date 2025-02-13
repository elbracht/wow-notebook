local addon = LibStub("AceAddon-3.0"):NewAddon("Notebook")
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Notebook", {
  type = "data source",
  icon = "Interface\\Icons\\inv_misc_note_02",
  OnClick = function()
    ToggleFrame(NotebookFrame)
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("Notebook")
        tooltip:AddLine("Left-click to open / close", 1, 1, 1)
    end,
})
local icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("NotebookDB", {
    profile = {
      minimap = {
        hide = false,
      },
    },
  })
  icon:Register("Notebook", LDB, self.db.profile.minimap)
end

function NotebookFrame_OnLoad(self)
  UIPanelWindows["NotebookFrame"] = { area = "left", pushable = 5 };
  SetPortraitToTexture(self.portrait, "Interface\\Spellbook\\Spellbook-Icon")
  self.TitleText:SetText("Notebook")
  self:RegisterForDrag("LeftButton");
end

function NotebookFrame_OnDragStart(self)
  self:StartMoving()
end

function NotebookFrame_OnDragStop(self)
  self:StopMovingOrSizing()
end
