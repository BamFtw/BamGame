class BamSubscriberParameters_TakeDamage extends BamSubscriberParameters;

var int Damage;

var Controller InstigatedBy;

var Vector HitLocation;

var Vector Momentum;

var class<DamageType> DamageType;

var TraceHitInfo HitInfo;

var Actor DamageCauser;


static function BamSubscriberParameters_TakeDamage Create(BamAIController ctrl, BamAIPawn pwn, int _damage, Controller _instigatedBy, vector _hitLocation, vector _momentum, class<DamageType> _damageType, optional TraceHitInfo _hitInfo, optional Actor _damageCauser)
{
	local BamSubscriberParameters_TakeDamage instance;

	instance = new default.class;

	instance.Controller = ctrl;
	instance.Pawn = pwn;

	instance.Damage = _damage;
	instance.InstigatedBy = _instigatedBy;
	instance.HitLocation = _hitLocation;
	instance.Momentum = _momentum;
	instance.DamageType = _damageType;
	instance.HitInfo = _hitInfo;
	instance.DamageCauser = _damageCauser;

	return instance;
}