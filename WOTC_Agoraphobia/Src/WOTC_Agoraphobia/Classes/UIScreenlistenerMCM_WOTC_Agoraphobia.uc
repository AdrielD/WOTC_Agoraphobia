class UIScreenlistenerMCM_WOTC_Agoraphobia extends UIScreenListener config(WOTCAgoraphobia_Settings);

`include(WOTC_Agoraphobia/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(WOTC_Agoraphobia/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var localized string strWOTCAgoraphobiaSecondWaveDescription;
var localized string strWOTCAgoraphobiaSecondWaveTooltip;

var config int MCM_ConfigVersion;

var config int MCM_WillPenaltyAtOpenGround;
var config int MCM_PanicChanceAtOpenGround;
var config int MCM_WillPenaltyAtLowCover;
var config int MCM_WillPenaltyChanceAtLowCover;
var config int MCM_PaniacChanceAtLowCover;
var config bool MCM_AlsoApplyToConcealedUnits;

var MCM_API_Slider SliderWillPenaltyAtOpenGround;
var MCM_API_Slider SliderPanicChanceAtOpenGround;
var MCM_API_Slider SliderWillPenaltyAtLowCover;
var MCM_API_Slider SliderWillPenaltyChanceAtLowCover;
var MCM_API_Slider SliderPaniacChanceAtLowCover;
var MCM_API_Checkbox CheckboxAlsoApplyToConcealedUnits;

`MCM_CH_VersionChecker(class'WOTCAgoraphobia_Defaults'.default.VERSION, MCM_ConfigVersion)

event OnInit(UIScreen Screen)
{
	if (MCM_API(Screen) != none)
	{
		`LOG("detected MCM", true, 'WOTC Agoraphobia');
		`MCM_API_Register(Screen, ClientModCallback);
	}
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup OpenGroundGroup;
	local MCM_API_SettingsGroup LowCoverGroup;
	local MCM_API_SettingsGroup OtherGroup;

	LoadSavedSettings();

	Page = ConfigAPI.NewSettingsPage("Agoraphobia");
	Page.SetPageTitle("Agoraphobia");
	Page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);

	OpenGroundGroup = Page.AddGroup('Group1', "When at open ground / no cover");
	OpenGroundGroup.AddSlider('open_ground_penalty', "Will penalty", "", 0, 100, 1, MCM_WillPenaltyAtOpenGround, , OpenGroundPenaltySaveHandler);
	OpenGroundGroup.AddSlider('open_ground_panic', "Panic chance", "", 0, 100, 1, MCM_PanicChanceAtOpenGround, , OpenGroundPanicChanceSaveHandler);

	Page.AddGroup('SpacingGroup1', "");

	LowCoverGroup = Page.AddGroup('Group2', "When at low cover");
	LowCoverGroup.AddSlider('low_cover_penalty', "Will penalty", "", 0, 100, 1, MCM_WillPenaltyAtLowCover, , LowCoverPenaltySaveHandler);
	LowCoverGroup.AddSlider('low_cover_penalty_chance', "Chance of will loss", "", 0, 100, 1, MCM_WillPenaltyChanceAtLowCover, , LowCoverPenaltyChanceSaveHandler);
	LowCoverGroup.AddSlider('low_cover_panic_chance', "Panic chance", "", 0, 100, 1, MCM_PaniacChanceAtLowCover, , LowCoverPanicChanceSaveHandler);
	
	Page.AddGroup('SpacingGroup2', "");

	OtherGroup = Page.AddGroup('Group3', "Miscellanious");
	OtherGroup.AddCheckbox('apply_to_conceaked', "Apply to concealed units", "", MCM_AlsoApplyToConcealedUnits, , ApplyToConcealedSaveHandler).SetEditable(true);

	Page.ShowSettings();
}

`MCM_API_BasicSliderSaveHandler(OpenGroundPenaltySaveHandler, MCM_WillPenaltyAtOpenGround);
`MCM_API_BasicSliderSaveHandler(OpenGroundPanicChanceSaveHandler, MCM_PanicChanceAtOpenGround);
`MCM_API_BasicSliderSaveHandler(LowCoverPenaltySaveHandler, MCM_WillPenaltyAtLowCover);
`MCM_API_BasicSliderSaveHandler(LowCoverPenaltyChanceSaveHandler, MCM_WillPenaltyChanceAtLowCover);
`MCM_API_BasicSliderSaveHandler(LowCoverPanicChanceSaveHandler, MCM_PaniacChanceAtLowCover);
`MCM_API_BasicCheckboxSaveHandler(ApplyToConcealedSaveHandler, MCM_AlsoApplyToConcealedUnits);

simulated function LoadSavedSettings()
{
	MCM_WillPenaltyAtOpenGround = `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.WILL_PENALTY_AT_OPEN_GROUND, MCM_WillPenaltyAtOpenGround);
	MCM_PanicChanceAtOpenGround = `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.PANIC_CHANCE_AT_OPEN_GROUND, MCM_PanicChanceAtOpenGround);
	MCM_WillPenaltyAtLowCover = `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.WILL_PENALTY_AT_LOW_COVER, MCM_WillPenaltyAtLowCover);
	MCM_WillPenaltyChanceAtLowCover = `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.WILL_PENALTY_CHANCE_AT_LOW_COVER, MCM_WillPenaltyChanceAtLowCover);
	MCM_PaniacChanceAtLowCover = `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.PANIC_CHANCE_AT_LOW_COVER, MCM_PaniacChanceAtLowCover);
	MCM_AlsoApplyToConcealedUnits = `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.ALSO_APPLY_TO_CONCEALED_UNITS, MCM_AlsoApplyToConcealedUnits);
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	SliderWillPenaltyAtOpenGround.SetValue(MCM_WillPenaltyAtOpenGround, true);
	SliderPanicChanceAtOpenGround.SetValue(MCM_PanicChanceAtOpenGround, true);
	SliderWillPenaltyAtLowCover.SetValue(MCM_WillPenaltyAtLowCover, true);
	SliderWillPenaltyChanceAtLowCover.SetValue(MCM_WillPenaltyChanceAtLowCover, true);
	SliderPaniacChanceAtLowCover.SetValue(MCM_PaniacChanceAtLowCover, true);
	CheckboxAlsoApplyToConcealedUnits.SetValue(MCM_AlsoApplyToConcealedUnits, true);
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	self.MCM_ConfigVersion = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

defaultproperties
{
    ScreenClass = none;
}