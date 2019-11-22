class X2EventListener_Agoraphobia extends X2EventListener
	dependson(Agoraphobia_DefaultSettings, XComGameStateContext_WillRoll);

`include(WOTC_Agoraphobia/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_StaticVersionChecker(class'Agoraphobia_DefaultSettings'.default.VERSION, class'Agoraphobia_MCMSettings'.default.MCM_Version)

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateWillPenaltyTemplate());
	
	return Templates;
}

static function X2EventListenerTemplate CreateWillPenaltyTemplate()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'AgoraphobiaWillPenalty');
	Template.RegisterInTactical = true;
	Template.AddEvent('PlayerTurnEnded', OnPlayerTurnEnded);

	return Template;
}

static protected function EventListenerReturn OnPlayerTurnEnded(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (XComGameState_Player(EventData).TeamFlag == eTeam_XCom && `SecondWaveEnabled('WOTCAgoraphobia'))
		ApplyWillPenaltyOnTurnEnd(EventData);

	return ELR_NoInterrupt;
}

static function bool ShouldRollAgoraphobia(XComGameState_Unit TargetUnit)
{
	local XComGameState_EvacZone EvacZone;

	EvacZone = class'XComGameState_EvacZone'.static.GetEvacZone(TargetUnit.GetTeam());

	if(TargetUnit.IsPlayerControlled()
		&& TargetUnit.UsesWillSystem()
		&& TargetUnit.CanTakeCover()
		&& !TargetUnit.IsUnconscious()
		&& !TargetUnit.IsDazed()
		&& !TargetUnit.IsMindControlled()
		&& !TargetUnit.bRemovedFromPlay
		&& !EvacZone.IsUnitInEvacZone(TargetUnit)
		&& class'Agoraphobia_DefaultSettings'.default.IGNORE_UNIT_TEMPLATES.Find(TargetUnit.GetMyTemplateName()) < 0)
	{
		if(DoesApplyToConcealedunits())
			return true;
		else
			return !TargetUnit.IsConcealed();
	}

	return false;
}

static function ApplyWillPenaltyOnTurnEnd(Object EventData)
{
	local XComGameState_Unit TargetUnit;
	local ECoverType CoverType;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', TargetUnit)
	{
		if(!ShouldRollAgoraphobia(TargetUnit))
			return;

		if(IsFlankingRuleEnabled() && TargetUnit.IsFlanked())
		{
			ApplyAgoraphobiaAtNoCover(TargetUnit);
			return;
		}

		CoverType = TargetUnit.GetCoverTypeFromLocation();

		if(CoverType == CT_None)
			ApplyAgoraphobiaAtNoCover(TargetUnit);
		else if(CoverType == CT_MidLevel)
			ApplyAgoraphobiaAtLowCover(TargetUnit);
		else if(CoverType == CT_Standing)
			ApplyAgoraphobiaAtHighCover(TargetUnit);
	}
}

static function ApplyAgoraphobia(XComGameState_Unit TargetUnit, int WillLoss, int LossChance, int PanicChance)
{
	local int FinalPanicChance;
	local bool IsUnitOnSmokeTile, IsUnitMarked, IsUnitImmune;

	IsUnitOnSmokeTile = TargetUnit.IsInWorldEffectTile(class'X2Effect_ApplySmokeGrenadeToWorld'.default.Class.Name);
	IsUnitMarked = TargetUnit.AffectedByEffectNames.Find('MarkedTarget') != INDEX_NONE;
	IsUnitImmune = TargetUnit.AffectedByEffectNames.Find('MindShieldImmunity') != INDEX_NONE;

	`LOG("SMOKE ON: " @ IsUnitOnSmokeTile @ " ALTERNATE: " @ TargetUnit.IsInWorldEffectTile(class'X2Effect_ApplySmokeGrenadeToWorld'.default.Class.Name), true, 'WOTC_agoraphobia');

	FinalPanicChance = PanicChance;

	if(IsUnitOnSmokeTile)
		FinalPanicChance = FinalPanicChance - (PanicChance * GetSmokePanicReduction() / 100);
	
	if(IsUnitMarked)
		FinalPanicChance = FinalPanicChance + (PanicChance * GetMarkedPanicIncrease() / 100);

	if(IsUnitImmune)
		LossChance = 0;

	if(Rand(100) < LossChance)
		SubmitUnitWillChangeToGameState(TargetUnit, WillLoss, FinalPanicChance);
}

static function ApplyAgoraphobiaAtNoCover(XComGameState_Unit TargetUnit)
{ ApplyAgoraphobia(TargetUnit, GetWillLossAtNoCover(), GetLossChanceAtNoCover(), GetPanicChanceAtNoCover()); }

static function ApplyAgoraphobiaAtLowCover(XComGameState_Unit TargetUnit)
{ ApplyAgoraphobia(TargetUnit, GetWillLossAtLowCover(), GetLossChanceAtLowCover(), GetPanicChanceAtLowCover()); }

static function ApplyAgoraphobiaAtHighCover(XComGameState_Unit TargetUnit)
{ ApplyAgoraphobia(TargetUnit, GetWillLossAtHighCover(),GetLossChanceAtHighCover(),  GetPanicChanceAtHighCover()); }

static function SubmitUnitWillChangeToGameState(XComGameState_Unit TargetUnit, int WillLossAmount, int PanicChance)
{
	local XComGameStateContext_WillRoll WillRollContext;
	local WillEventRollData_PanicWeight PanicWeight;
	local WillEventRollData AgoraphobiaWillRollData;

	AgoraphobiaWillRollData.WillLossChance = 1;
	AgoraphobiaWillRollData.FlatWillLossChance = true;
	AgoraphobiaWillRollData.WillLossStat = WillEventRollStat_Flat;
	AgoraphobiaWillRollData.WillLossStatMultiplier = 1.0;
	AgoraphobiaWillRollData.MinimumWillLoss = WillLossAmount;
	AgoraphobiaWillRollData.CanZeroOutWill = true;
	AgoraphobiaWillRollData.PanicChance = PanicChance * 0.01;

	PanicWeight.PanicAbilityName = 'Panicked';
	PanicWeight.Weight = 1;
	AgoraphobiaWillRollData.PanicWeights.AddItem(PanicWeight);

	PanicWeight.PanicAbilityName = 'Shattered';
	PanicWeight.Weight = 1;
	AgoraphobiaWillRollData.PanicWeights.AddItem(PanicWeight);
	
	WillRollContext = class'XComGameStateContext_WillRoll'.static.CreateWillRollContext(TargetUnit, 'Agoraphobia', "Agoraphobia", true);
	WillRollContext.DoWillRoll(AgoraphobiaWillRollData);
	WillRollContext.Submit();
}

// High Cover
static function int GetWillLossAtHighCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.WILL_LOSS, class'Agoraphobia_MCMSettings'.default.MCM_HighCover.WillLoss); }

static function int GetLossChanceAtHighCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.LOSS_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_HighCover.LossChance); }

static function int GetPanicChanceAtHighCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.HIGH_COVER.PANIC_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_HighCover.PanicChance); }

// Low Cover
static function int GetWillLossAtLowCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.LOW_COVER.WILL_LOSS, class'Agoraphobia_MCMSettings'.default.MCM_LowCover.WillLoss); }

static function int GetLossChanceAtLowCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.LOW_COVER.LOSS_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_LowCover.LossChance); }

static function int GetPanicChanceAtLowCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.LOW_COVER.PANIC_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_LowCover.PanicChance); }

// No Cover
static function int GetWillLossAtNoCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.NO_COVER.WILL_LOSS, class'Agoraphobia_MCMSettings'.default.MCM_NoCover.WillLoss); }

static function int GetLossChanceAtNoCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.NO_COVER.LOSS_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_NoCover.LossChance); }

static function int GetPanicChanceAtNoCover()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.NO_COVER.PANIC_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_NoCover.PanicChance); }

// Miscellanious
static function bool IsFlankingRuleEnabled()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.APPLY_FLANKING_RULES, class'Agoraphobia_MCMSettings'.default.MCM_ApplyFlankingRules); }

static function int GetSmokePanicReduction()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.SMOKE_REDUCES_PANIC_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_SmokePanicReduction); }

static function int GetMarkedPanicIncrease()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.MARKED_INCREASES_PANIC_CHANCE, class'Agoraphobia_MCMSettings'.default.MCM_MarkedPanicIncrease); }

static function bool DoesApplyToConcealedunits()
{ return `MCM_CH_GetValue(class'Agoraphobia_DefaultSettings'.default.ALSO_APPLY_TO_CONCEALED_UNITS, class'Agoraphobia_MCMSettings'.default.MCM_AlsoApplyToConcealedUnits); }