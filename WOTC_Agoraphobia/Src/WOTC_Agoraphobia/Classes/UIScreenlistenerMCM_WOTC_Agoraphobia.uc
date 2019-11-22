class UIScreenlistenerMCM_WOTC_Agoraphobia extends UIScreenListener;

`include(WOTC_Agoraphobia/Src/ModConfigMenuAPI/MCM_API_Includes.uci)

var Agoraphobia_MCMSettings Settings;
var localized string strFlankingRulesDescription;

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
	local MCM_API_SettingsGroup NoCoverGroup, LowCoverGroup, HighCoverGroup, OtherGroup;

	Settings = new(self) class'Agoraphobia_MCMSettings';
	Settings.LoadConfigs();

	Page = ConfigAPI.NewSettingsPage("Agoraphobia");
	Page.SetPageTitle("Agoraphobia");
	Page.SetSaveHandler(Settings.SaveConfigs);
	Page.EnableResetButton(ResetButtonClicked);

	NoCoverGroup = Page.AddGroup('NoCoverSettings', "When at open ground / no cover");
	NoCoverGroup.AddSlider('nc_wl', "Will loss", "", 0, 100, 1, Settings.MCM_NoCover.WillLoss, , NCWLSaveHandler);
	NoCoverGroup.AddSlider('nc_lc', "Loss chance", "", 0, 100, 1, Settings.MCM_NoCover.LossChance, , NCLCSaveHandler);
	NoCoverGroup.AddSlider('nc_pc', "Panic chance", "", 0, 100, 1, Settings.MCM_NoCover.PanicChance, , NCPCSaveHandler);

	Page.AddGroup('SpacingGroup1', "");

	LowCoverGroup = Page.AddGroup('LowCoverSettings', "When at low cover");
	LowCoverGroup.AddSlider('lc_wl', "Will loss", "", 0, 100, 1, Settings.MCM_LowCover.WillLoss, , LCWLSaveHandler);
	LowCoverGroup.AddSlider('lc_lc', "Loss chance", "", 0, 100, 1, Settings.MCM_LowCover.LossChance, , LCLCSaveHandler);
	LowCoverGroup.AddSlider('lc_pc', "Panic chance", "", 0, 100, 1, Settings.MCM_LowCover.PanicChance, , LCPCSaveHandler);

	Page.AddGroup('SpacingGroup2', "");

	HighCoverGroup = Page.AddGroup('HighCoverSettings', "When at high cover");
	HighCoverGroup.AddSlider('hc_wl', "Will loss", "", 0, 100, 1, Settings.MCM_HighCover.WillLoss, , HCWLSaveHandler);
	HighCoverGroup.AddSlider('hc_lc', "Loss chance", "", 0, 100, 1, Settings.MCM_HighCover.LossChance, , HCLCSaveHandler);
	HighCoverGroup.AddSlider('hc_pc', "Panic chance", "", 0, 100, 1, Settings.MCM_HighCover.PanicChance, , HCPCSaveHandler);

	Page.AddGroup('SpacingGroup3', "");

	OtherGroup = Page.AddGroup('MiscellaniousSettings', "Miscellanious");
	OtherGroup.AddCheckbox('flanking_rules', "Apply flanking rules", strFlankingRulesDescription, Settings.MCM_ApplyFlankingRules, , FlankingRuleSaveHandler).SetEditable(true);
	OtherGroup.AddSlider('smoke_reducer', "Smoke reduces panic chance by this %", "", 0, 100, 1, Settings.MCM_SmokePanicReduction, , SmokeReductionSaveHandler);
	OtherGroup.AddSlider('marked_increaser', "Being marked target increases panic chance by this %", "", 0, 100, 1, Settings.MCM_MarkedPanicIncrease, , MarkedIncreaseSaveHandler);
	OtherGroup.AddCheckbox('apply_to_concealed', "Apply to concealed units", "", Settings.MCM_AlsoApplyToConcealedUnits, , ConcealedSaveHandler).SetEditable(true);

	Page.ShowSettings();
}

`MCM_API_BasicSliderSaveHandler(NCWLSaveHandler, Settings.MCM_NoCover.WillLoss);
`MCM_API_BasicSliderSaveHandler(NCLCSaveHandler, Settings.MCM_NoCover.LossChance);
`MCM_API_BasicSliderSaveHandler(NCPCSaveHandler, Settings.MCM_NoCover.PanicChance);

`MCM_API_BasicSliderSaveHandler(LCWLSaveHandler, Settings.MCM_LowCover.WillLoss);
`MCM_API_BasicSliderSaveHandler(LCLCSaveHandler, Settings.MCM_LowCover.LossChance);
`MCM_API_BasicSliderSaveHandler(LCPCSaveHandler, Settings.MCM_LowCover.PanicChance);

`MCM_API_BasicSliderSaveHandler(HCWLSaveHandler, Settings.MCM_HighCover.WillLoss);
`MCM_API_BasicSliderSaveHandler(HCLCSaveHandler, Settings.MCM_HighCover.LossChance);
`MCM_API_BasicSliderSaveHandler(HCPCSaveHandler, Settings.MCM_HighCover.PanicChance);

`MCM_API_BasicCheckboxSaveHandler(FlankingRuleSaveHandler, Settings.MCM_ApplyFlankingRules);
`MCM_API_BasicSliderSaveHandler(SmokeReductionSaveHandler, Settings.MCM_SmokePanicReduction);
`MCM_API_BasicSliderSaveHandler(MarkedIncreaseSaveHandler, Settings.MCM_MarkedPanicIncrease);
`MCM_API_BasicCheckboxSaveHandler(ConcealedSaveHandler, Settings.MCM_AlsoApplyToConcealedUnits);

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	ResetSlider(Page, 'NoCoverSettings', 'nc_wl', class'Agoraphobia_DefaultSettings'.default.NO_COVER.WILL_LOSS);
	ResetSlider(Page, 'NoCoverSettings', 'nc_lc', class'Agoraphobia_DefaultSettings'.default.NO_COVER.LOSS_CHANCE);
	ResetSlider(Page, 'NoCoverSettings', 'nc_pc', class'Agoraphobia_DefaultSettings'.default.NO_COVER.PANIC_CHANCE);

	ResetSlider(Page, 'LowCoverSettings', 'lc_wl', class'Agoraphobia_DefaultSettings'.default.LOW_COVER.WILL_LOSS);
	ResetSlider(Page, 'LowCoverSettings', 'lc_lc', class'Agoraphobia_DefaultSettings'.default.LOW_COVER.LOSS_CHANCE);
	ResetSlider(Page, 'LowCoverSettings', 'lc_pc', class'Agoraphobia_DefaultSettings'.default.LOW_COVER.PANIC_CHANCE);

	ResetSlider(Page, 'HighCoverSettings', 'hc_wl', class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.WILL_LOSS);
	ResetSlider(Page, 'HighCoverSettings', 'hc_lc', class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.LOSS_CHANCE);
	ResetSlider(Page, 'HighCoverSettings', 'hc_pc', class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.PANIC_CHANCE);

	ResetCheckbox(Page, 'MiscellaniousSettings', 'flanking_rules', class'Agoraphobia_DefaultSettings'.default.APPLY_FLANKING_RULES);
	ResetSlider(Page, 'MiscellaniousSettings', 'smoke_reducer', class'Agoraphobia_DefaultSettings'.default.SMOKE_REDUCES_PANIC_CHANCE);
	ResetSlider(Page, 'MiscellaniousSettings', 'marked_increaser', class'Agoraphobia_DefaultSettings'.default.MARKED_INCREASES_PANIC_CHANCE);
	ResetCheckbox(Page, 'MiscellaniousSettings', 'apply_to_concealed', class'Agoraphobia_DefaultSettings'.default.ALSO_APPLY_TO_CONCEALED_UNITS);
}

simulated function ResetCheckbox(MCM_API_SettingsPage Page, name GroupName, name SettingName, bool Value)
{
	local MCM_API_SettingsGroup Group;
	local MCM_API_Setting Setting;
	local MCM_API_Checkbox Checkbox;
	
	Group = Page.GetGroupByName(GroupName);
	Setting = Group.GetSettingByName(SettingName);
	Checkbox = MCM_API_Checkbox(Setting);
	Checkbox.SetValue(Value, false);
}

simulated function ResetSlider(MCM_API_SettingsPage Page, name GroupName, name SettingName, int Value)
{
	local MCM_API_SettingsGroup Group;
	local MCM_API_Setting Setting;
	local MCM_API_Slider Slider;

	Group = Page.GetGroupByName(GroupName);
	Setting = Group.GetSettingByName(SettingName);
	Slider = MCM_API_Slider(Setting);
	Slider.SetValue(value, false);
}

defaultproperties
{
    ScreenClass = none;
}