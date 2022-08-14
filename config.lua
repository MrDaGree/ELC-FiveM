printDebugInformation = true
runDebug = false
versionCheck = true
openPanelByDefault = true

-- Higher number for slower lights
flashBPM = 280
-- higher for higher flashBPM, lower for lower flashBPM
lightDensity = 6

-- how close you need to be in order for these lights to flash
mainLoadDist = 150
trafLoadDist = 45

maximizePerformance = true

-- all environmental lighting brightness
envLightBrightness = 0.5
envLightDistance = 50.5
envTALightDistance = 35.5

-- alley light distance
alleyLightDistance = 150.5
alleyLightBrightness = 3.5

controls = {
  ['stage'] = { type = "keyboard", key = "j" },
  ['frontpatternchange'] = { type = "keyboard", key = "l" },
  ['rearpatternchange'] = { type = "keyboard", key = "semicolon" },
  ['sirentoneone'] = { type = "keyboard", key = "1" },
  ['sirentonetwo'] = { type = "keyboard", key = "2" },
  ['sirentonethree'] = { type = "keyboard", key = "3" },
  ['sirencycle'] = { type = "keyboard", key = "r" },
  ['sirentoggle'] = { type = "keyboard", key = "lmenu" },
  ['mantonetoggle'] = { type = "keyboard", key = "x" },
  ['toggleta-right'] = { type = "keyboard", key = "i" },
  ['toggleta-center'] = { type = "keyboard", key = "u" },
  ['toggleta-left'] = { type = "keyboard", key = "y" },
  ['cruisetoggle'] = { type = "keyboard", key = "k" },
  ['steadyburntoggle'] = { type = "keyboard", key = "o" },
  ['toggleleftalley'] = { type = "keyboard", key = "lbracket" },
  ['togglerightalley'] = { type = "keyboard", key = "rbracket" },
  ['toggletakedowns'] = { type = "keyboard", key = "backslash" },
  ['paneltoggle'] = { type = "keyboard", key = "p" },
  ['modifier'] = { type = "keyboard", key = "rmenu" },
  ['lock'] = { type = "keyboard", key = "insert" },
}