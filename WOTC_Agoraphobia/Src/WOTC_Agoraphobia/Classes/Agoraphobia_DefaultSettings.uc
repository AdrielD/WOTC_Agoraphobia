class Agoraphobia_DefaultSettings extends Object config(Agoraphobia_DefaultSettings);

struct CoverType
{
	var config int WILL_LOSS;
	var config int LOSS_CHANCE;
	var config int PANIC_CHANCE;
};

var config CoverType HIGH_COVER;
var config CoverType LOW_COVER;
var config CoverType NO_COVER;

var config bool APPLY_FLANKING_RULES;
var config int SMOKE_REDUCES_PANIC_CHANCE;
var config int MARKED_INCREASES_PANIC_CHANCE;
var config bool ALSO_APPLY_TO_CONCEALED_UNITS;
var config array<name> IGNORE_UNIT_TEMPLATES;

var config int VERSION;