local notebookFrame = nil
local editBox = nil
local placeholder = nil

local isFirstLoad = true

local addon = LibStub("AceAddon-3.0"):NewAddon("Notebook")

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Notebook", {
  type = "data source",
  icon = "Interface\\Icons\\inv_misc_note_02",
  OnClick = function()
    if InCombatLockdown() then
      if NotebookFrame:IsShown() then
        NotebookFrame:Hide()
      else
        NotebookFrame:Show()
      end
    else
      ToggleFrame(NotebookFrame)
    end
  end,
  OnTooltipShow = function(tooltip)
    tooltip:SetText("Notebook")
    tooltip:AddLine("|cFFa6a6a6Left Click:|r Toggle Notebook")
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
  editBox:SetText(addon.db.profile.note)
end

function onShow()
  PlaySound(844) -- SOUNDKIT.IG_QUEST_LOG_OPEN
end

function onHide()
  PlaySound(845) -- SOUNDKIT.IG_QUEST_LOG_CLOSE
end

function onUpdate(self, elapsed)
  -- any mouse click anywhere else will remove focus from edit box
  local isDown = IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")
  if not self:IsMouseOver() and isDown then
    editBox:ClearFocus()
  end
end

function onMouseDown(self, button)
  if button == "LeftButton" then
    editBox:SetFocus()
  end
end

function onDragStart(self)
  self:StartMoving()
end

function onDragStop(self)
  self:StopMovingOrSizing()
end

function onEditTextChanged(self)
  -- Save the text to db
  addon.db.profile.note = self:GetText()

  -- Scroll to the bottom if already at the bottom
  local scrollFrame = self:GetParent()
  local scrollBar = scrollFrame.ScrollBar
  local min, max = scrollBar:GetMinMaxValues()

  if scrollBar:GetValue() >= max - 20 then
      scrollBar:SetValue(max)
  end

  -- Update placebolder
  if self:GetText() == "" then
    placeholder:Show()
  else
    placeholder:Hide()
  end
end

function onEditEscapePressed(self)
  self:ClearFocus()
end

local function createNotebookFrame()
  -- Create the frame
  notebookFrame = CreateFrame("Frame", "NotebookFrame", UIParent, "BasicFrameTemplate")

  -- Set the size and properties for the frame
  notebookFrame:SetSize(336, 424)
  notebookFrame:SetToplevel(true)
  notebookFrame:SetMovable(true)
  notebookFrame:EnableMouse(true)
  notebookFrame:Hide()

  -- Register frame as UI panel
  UIPanelWindows["NotebookFrame"] = { area = "left", pushable = 5 }

  -- Set the title text and position it
  notebookFrame.TitleText:SetText("Notebook")
  notebookFrame.TitleText:ClearAllPoints()
  notebookFrame.TitleText:SetPoint("TOP", notebookFrame, "TOP", 0, -6)

  -- Drag functionality: Enable dragging with the left mouse button
  notebookFrame:RegisterForDrag("LeftButton")

  -- Register the frame scripts with the event handler functions
  notebookFrame:SetScript("OnShow", onShow)
  notebookFrame:SetScript("OnHide", onHide)
  notebookFrame:SetScript("OnUpdate", onUpdate)
  notebookFrame:SetScript("OnMouseDown", onMouseDown)
  notebookFrame:SetScript("OnDragStart", onDragStart)
  notebookFrame:SetScript("OnDragStop", onDragStop)

  -- Set the background texture
  local bgTexture = notebookFrame:CreateTexture(nil, "ARTWORK")
  bgTexture:SetPoint("TOPLEFT", 3, -22) -- left, top
  bgTexture:SetPoint("BOTTOMRIGHT", -4, 4) -- right, bottom
  bgTexture:SetTexture("Interface\\AddOns\\Notebook\\Assets\\BG")

  -- Create a ScrollFrame to make the EditBox scrollable
  local scrollFrame = CreateFrame("ScrollFrame", nil, notebookFrame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 6, -26) -- left, top
  scrollFrame:SetPoint("BOTTOMRIGHT", -30, 6) -- right, bottom

  -- Create an EditBox inside the ScrollFrame
  editBox = CreateFrame("EditBox", nil, scrollFrame)
  editBox:SetSize(290, 0)
  editBox:SetFontObject("GameFontNormal_NoShadow")
  editBox:SetTextColor(0, 0, 0, 0.8)
  editBox:SetHighlightColor(0.82, 0.82, 0.82, 1.0)
  editBox:SetTextInsets(28, 28, 30, 30)
  editBox:SetMultiLine(true)
  editBox:SetAutoFocus(false)

  editBox:SetScript("OnTextChanged", onEditTextChanged)
  editBox:SetScript("OnEscapePressed", onEditEscapePressed)

  -- Make sure EditBox content can be scrolled
  scrollFrame:SetScrollChild(editBox)

  -- Placeholder
  placeholder = editBox:CreateFontString(nil, "OVERLAY", "GameFontNormal_NoShadow")
  placeholder:SetPoint("LEFT", editBox, "LEFT", 28, 0)
  placeholder:SetText("Enter text here...")
  placeholder:SetTextColor(0, 0, 0, 0.5)
end

-- Create the notebook frame by calling the function
createNotebookFrame()
