class BamSubscriberParameters_HearNoise extends BamSubscriberParameters;

var float Loudness;

var Actor NoiseMaker;

var Name NoiseType;

static function BamSubscriberParameters_HearNoise Create(BamAIController ctrl, BamAIPawn pwn, float _loudnes, Actor _noiseMaker, optional Name _noiseType)
{
	local BamSubscriberParameters_HearNoise instance;

	instance = new default.class;

	instance.Controller = ctrl;
	instance.Pawn = pwn;

	instance.Loudness = _loudnes;
	instance.NoiseMaker = _noiseMaker;
	instance.NoiseType = _noiseType;

	return instance;
}