require "/interface/scripted/starcustomchatsettings/settingsplugin.lua"
require "/scripts/messageutil.lua"

languages = SettingsPluginClass:new(
  { name = "languages" }
)

function languages:init()
  self:_loadConfig()

  self.languagesLevels = player.getProperty("scc_rp_languages", {})
  self.serverLanguagesData = nil

  if self.stagehandType then
    starcustomchat.utils.sendMessageToStagehand(self.stagehandType, "scc_retreive_languages", nil, function(languagesList) 
      if languagesList then 
        self:buildLanguagesList(languagesList) 
      else
        self.widget.setVisible("lblWarningNoLanguagesSupport", true)
      end
    end, function()
      self.widget.setVisible("lblWarningNoLanguagesSupport", true)
    end)
  else
    self.widget.setVisible("lblWarningLanguagesDisabled", true)
  end
end

function languages:buildLanguagesList(languagesList)
  self.widget.clearListItems("saLanguages.listItems")
  self.serverLanguagesData = copy(languagesList)
  self.widget.setVisible("saLanguages", true)
  self.widget.clearListItems("saLanguages.listItems")

  for code, language in pairs(languagesList) do
    local li = self.widget.addListItem("saLanguages.listItems")
    self.widget.setText("saLanguages.listItems." .. li .. ".name", language.name)
    self.widget.setData("saLanguages.listItems." .. li, code)
  end

end

function languages:getSelectedLanguageData()
  local li = self.widget.getListSelected("saLanguages.listItems")
  if li then
    return self.widget.getData("saLanguages.listItems." .. li)
  end
end


function languages:selectLanguage()

  -- I don't know why, but all the kids are visible...
  self.widget.setVisible("lblLanguageName", true)
  self.widget.setVisible("lblDescription", true)
  self.widget.setVisible("lblDifficultyValue", true)
  self.widget.setVisible("lblKnowledgeHint", true)
  self.widget.setVisible("lblKnowledgePercent", true)
  self.widget.setVisible("spnKnowledge", true)
  self.widget.setVisible("lblDifficultyHint", true)


  local code = self:getSelectedLanguageData()
  if code then
    self.widget.setText("lblLanguageName", self.serverLanguagesData[code].name)
    self.widget.setText("lblDescription", self.serverLanguagesData[code].description or "")

    local diff = self.serverLanguagesData[code].difficulty
    self.widget.setText("lblDifficultyValue", diff and (diff == 0 and starcustomchat.utils.getTranslation("settings.plugins.languages.difficulty_zero") or diff) or 1)
    
    self:printCurrentLevel(self.languagesLevels[code] and self.languagesLevels[code].knowledge, diff)
  end
end


function languages:printCurrentLevel(level, max)
  local percentLevel = 0
  level = level or 0
  max = max or 1

  if max == 0 then
    percentLevel = 100
  else
    percentLevel = level / max * 100
  end
  self.widget.setText("lblKnowledgePercent", string.format("%.0f%%", percentLevel))
end

languages.spnKnowledge = {}

function languages.spnKnowledge:up()

  local code = self:getSelectedLanguageData()
  if code then
    local currentKnowledge = self.languagesLevels[code] and self.languagesLevels[code].knowledge or 0
    currentKnowledge = math.max(0, math.min(currentKnowledge + 1, self.serverLanguagesData[code].difficulty or 1))
    self.languagesLevels[code] = {
      knowledge = currentKnowledge
    }
    player.setProperty("scc_rp_languages", self.languagesLevels)
    self:printCurrentLevel(currentKnowledge, self.serverLanguagesData[code].difficulty)
    save()
  end
end

function languages.spnKnowledge:down()
  local code = self:getSelectedLanguageData()
  if code then
    local currentKnowledge = self.languagesLevels[code] and self.languagesLevels[code].knowledge or 0
    currentKnowledge = math.max(0, math.min(currentKnowledge - 1, self.serverLanguagesData[code].difficulty or 1))
    self.languagesLevels[code] = {
      knowledge = currentKnowledge
    }
    player.setProperty("scc_rp_languages", self.languagesLevels)
    self:printCurrentLevel(currentKnowledge, self.serverLanguagesData[code].difficulty)
    save()
  end
end

function languages:update(dt)
  promises:update()
end