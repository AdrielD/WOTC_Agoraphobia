class X2EventListener_Agoraphobia extends X2EventListener
	dependson(XComGameStateContext_WillRoll)
	config(WOTCAgoraphobia);

// Agoraphobia configurable variables
var config int WILL_PENALTY_AT_OPEN_GROUND;
var config int PANIC_CHANCE_AT_OPEN_GROUND;
var config int WILL_PENALTY_AT_LOW_COVER;
var config int WILL_PENALTY_CHANCE_AT_LOW_COVER;
var config int PANIC_CHANCE_AT_LOW_COVER;
var config bool ALSO_APPLY_TO_CONCEALED_UNITS;

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
	if(TargetUnit.UsesWillSystem() && TargetUnit.CanTakeCover())
	{
		if(default.ALSO_APPLY_TO_CONCEALED_UNITS)
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
	if(Rand(100) <= default.WILL_PENALTY_CHANCE_AT_LOW_COVER)
		SubmitUnitWillChangeToGameState(TargetUnit, default.WILL_PENALTY_AT_LOW_COVER, default.PANIC_CHANCE_AT_LOW_COVER);
}

static function ApplyAgoraphobiaAtOpenGround(XComGameState_Unit TargetUnit)
{
	SubmitUnitWillChangeToGameState(TargetUnit, default.WILL_PENALTY_AT_OPEN_GROUND, default.PANIC_CHANCE_AT_OPEN_GROUND);
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
