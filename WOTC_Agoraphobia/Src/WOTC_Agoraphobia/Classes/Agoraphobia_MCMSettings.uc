class Agoraphobia_MCMSettings extends Object config(Agoraphobia_MCMSettings);

struct CoverType
{
	var config int WillLoss;
	var config int LossChance;
	var config int PanicChance;
};

var config CoverType MCM_HighCover;
var config CoverType MCM_LowCover;
var config CoverType MCM_NoCover;

var config bool MCM_AlsoApplyToConcealedUnits;

var config int MCM_Version;

`include(WOTC_Agoraphobia/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'Agoraphobia_DefaultSettings'.default.VERSION, default.MCM_Version)

function LoadConfigs()
{
	MCM_HighCover.WillLoss = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.WILL_LOSS, MCM_HighCover.WillLoss);
	MCM_HighCover.LossChance = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.LOSS_CHANCE, MCM_HighCover.LossChance);
	MCM_HighCover.PanicChance = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.PANIC_CHANCE, MCM_HighCover.PanicChance);
	MCM_LowCover.WillLoss = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.LOW_COVER.WILL_LOSS, MCM_LowCover.WillLoss);
	MCM_LowCover.LossChance = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.LOW_COVER.LOSS_CHANCE, MCM_LowCover.LossChance);
	MCM_LowCover.PanicChance = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.LOW_COVER.PANIC_CHANCE, MCM_LowCover.PanicChance);
	MCM_NoCover.WillLoss = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.NO_COVER.WILL_LOSS, MCM_NoCover.WillLoss);
	MCM_NoCover.LossChance = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.NO_COVER.LOSS_CHANCE, MCM_NoCover.LossChance);
	MCM_NoCover.PanicChance = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.NO_COVER.PANIC_CHANCE, MCM_NoCover.PanicChance);
	MCM_AlsoApplyToConcealedUnits = `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.ALSO_APPLY_TO_CONCEALED_UNITS, MCM_AlsoApplyToConcealedUnits);
}

function SaveConfigs(MCM_API_SettingsPage Page)
{
	self.MCM_Version = `MCM_CH_GetCompositeVersion();
    self.SaveConfig(); 
}

function ResetConfigs(MCM_API_SettingsPage Page)
{
}