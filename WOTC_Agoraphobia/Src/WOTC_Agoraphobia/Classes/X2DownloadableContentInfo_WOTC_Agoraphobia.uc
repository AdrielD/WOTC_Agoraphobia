//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTC_Agoraphobia.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTC_Agoraphobia extends X2DownloadableContentInfo;

// Second Wave List Entry Variables
var localized string strWOTCAgoraphobiaDescription;
var localized string strWOTCAgoraphobiaTooltip;

static event OnPostTemplatesCreated()
{
	UpdateSecondWaveOptionsList();
}

// Add the Agoraphobia option to the Second Wave Advanced Options list
static function UpdateSecondWaveOptionsList()
{
	local array<Object> UIShellDifficultyArray;
	local Object ArrayObject;
	local UIShellDifficulty UIShellDifficulty;
    local SecondWaveOption WOTCAgoraphobia_Option;

	WOTCAgoraphobia_Option.ID = 'WOTCAgoraphobia';
	WOTCAgoraphobia_Option.DifficultyValue = 0;

	UIShellDifficultyArray = class'XComEngine'.static.GetClassDefaultObjects(class'UIShellDifficulty');
	foreach UIShellDifficultyArray(ArrayObject)
	{
		UIShellDifficulty = UIShellDifficulty(ArrayObject);
		UIShellDifficulty.SecondWaveOptions.AddItem(WOTCAgoraphobia_Option);
		UIShellDifficulty.SecondWaveDescriptions.AddItem(default.strWOTCAgoraphobiaDescription);
		UIShellDifficulty.SecondWaveToolTips.AddItem(default.strWOTCAgoraphobiaTooltip);
	}
}
