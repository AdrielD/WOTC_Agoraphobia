class X2EventListener_Agoraphobia extends X2EventListener
	dependson(XComGameStateContext_WillRoll);

`include(WOTC_Agoraphobia/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

`MCM_CH_StaticVersionChecker(class'WOTCAgoraphobia_Defaults'.default.VERSION, class'UIScreenlistenerMCM_WOTC_Agoraphobia'.default.MCM_ConfigVersion)

static function int GetWillPenaltyAtOpenGround()
{
	return `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.WILL_PENALTY_AT_OPEN_GROUND, class'UIScreenlistenerMCM_WOTC_Agoraphobia'.default.MCM_WillPenaltyAtOpenGround);
}

static function int GetPanicChanceAtOpenGround()
{
	return `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.PANIC_CHANCE_AT_OPEN_GROUND, class'UIScreenlistenerMCM_WOTC_Agoraphobia'.default.MCM_PanicChanceAtOpenGround);
}

static function int GetWillPenaltyAtLowCover()
{
	return `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.WILL_PENALTY_AT_LOW_COVER, class'UIScreenlistenerMCM_WOTC_Agoraphobia'.default.MCM_WillPenaltyAtLowCover);
}

static function int GetWillPenaltyChanceAtLowCover()
{
	return `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.WILL_PENALTY_CHANCE_AT_LOW_COVER, class'UIScreenlistenerMCM_WOTC_Agoraphobia'.default.MCM_WillPenaltyChanceAtLowCover);
}

static function int GetPaniacChanceAtLowCover()
{
	return `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.PANIC_CHANCE_AT_LOW_COVER, class'UIScreenlistenerMCM_WOTC_Agoraphobia'.default.MCM_PaniacChanceAtLowCover);
}

static function bool GetAlsoApplyToConcealedUnits()
{
	return `MCM_CH_GetValue(class'WOTCAgoraphobia_Defaults'.default.ALSO_APPLY_TO_CONCEALED_UNITS, class'UIScreenlistenerMCM_WOTC_Agoraphobia'.default.MCM_AlsoApplyToConcealedUnits);
}

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
		&& !TargetUnit.bRemovedFromPlay
		&& !EvacZone.IsUnitInEvacZone(TargetUnit)
		&& class'WOTCAgoraphobia_Defaults'.default.IGNORE_UNIT_TEMPLATES.Find(TargetUnit.GetMyTemplateName()) < 0)
	{
		if(GetAlsoApplyToConcealedUnits())
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
		if(ShouldRollAgoraphobia(TargetUnit))
		{
			CoverType = TargetUnit.GetCoverTypeFromLocation();

			if(CoverType == CT_MidLevel)
				ApplyAgoraphobiaAtLowCover(TargetUnit);
			else if(CoverType == CT_None)
				ApplyAgoraphobiaAtOpenGround(TargetUnit);
		}
	}
}

static function ApplyAgoraphobiaAtLowCover(XComGameState_Unit TargetUnit)
{
	if(Rand(100) <= GetWillPenaltyChanceAtLowCover())
		SubmitUnitWillChangeToGameState(TargetUnit, GetWillPenaltyAtLowCover(), GetPaniacChanceAtLowCover());
}

static function ApplyAgoraphobiaAtOpenGround(XComGameState_Unit TargetUnit)
{
	SubmitUnitWillChangeToGameState(TargetUnit, GetWillPenaltyAtOpenGround(), GetPanicChanceAtOpenGround());
}

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
