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

  NotebookFrame.editBox:SetText(self.db.profile.note)
end

function NotebookFrame_OnLoad(self)
  UIPanelWindows["NotebookFrame"] = { area = "left", pushable = 5 };
  SetPortraitToTexture(self.portrait, "Interface\\Spellbook\\Spellbook-Icon")
  self.TitleText:SetText("Notebook")
  self:RegisterForDrag("LeftButton");
end

function NotebookFrame_OnUpdate(self, elapsed)
	-- any mouse click anywhere else will remove focus from edit box
	local isDown = IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")
	if not self:IsMouseOver() and isDown then
		self.editBox:ClearFocus()
	end
end

function NotebookFrame_OnDragStart(self)
  self:StartMoving()
end

function NotebookFrame_OnDragStop(self)
  self:StopMovingOrSizing()
end

function NotebookFrameEditBox_OnTextChanged(self)
	local editBoxText = self:GetText()
  addon.db.profile.note = editBoxText
end
