/*
 * Author: TCVM
 * Deploys the current CSW
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_csw_fnc_assemble_deployWeapon
 *
 * Public: No
 */
#include "script_component.hpp"

[{
    params ["_tripod", "_player"];
    TRACE_2("assemble_deployWeapon",_tripod,_player);

    private _carryWeaponClassname = secondaryWeapon _player;
    private _tripodClassname = typeOf _tripod;
    _player removeWeaponGlobal _carryWeaponClassname;

    private _assembledClassname = getText(configfile >> "CfgWeapons" >> _carryWeaponClassname >> QUOTE(ADDON) >> "assembleTo" >> _tripodClassname);
    private _deployTime =  getNumber(configfile >> "CfgWeapons" >> _carryWeaponClassname >> QUOTE(ADDON) >> "deployTime");
    if (!isClass (configFile >> "CfgVehicles" >> _assembledClassname)) exitWith {ERROR_1("bad static classname [%1]",_assembledClassname);};

    TRACE_4("",_carryWeaponClassname,_tripodClassname,_assembledClassname,_deployTime);

    private _onFinish = {
        params ["_args"];
        _args params ["_tripod", "_player", "_assembledClassname"];
        TRACE_3("deployWeapon finish",_tripod,_player,_assembledClassname);

        private _tripodPos = getPosATL _tripod;
        private _tripodDir = getDir _tripod;
        deleteVehicle _tripod;

        _tripodPos set [2, (_tripodPos select 2) + 0.1];
        private _csw = createVehicle [_assembledClassname, [0, 0, 0], [], 0, "NONE"];
        _csw setVariable [QGVAR(assemblyMode), 1, true]; // Explicitly set advanced assembly mode and broadcast
        _csw setVariable [QGVAR(emptyWeapon), true, false]; // unload gun, shouldn't need broadcast for this as it will be local to us
        _csw setPosATL _tripodPos;
        _csw setDir _tripodDir;
        _csw setVectorUp (surfaceNormal _tripodPos);
    };

    private _onFailure = {
        params ["_args"];
        _args params ["", "_player", "", "_carryWeaponClassname"];
        TRACE_2("deployWeapon failure",_player,_carryWeaponClassname);

        _player addWeaponGlobal _carryWeaponClassname;
    };

    private _codeCheck = {
        params ["_args"];
        _args params ["_tripod"];
        !isNull _tripod;
    };

    [TIME_PROGRESSBAR(_deployTime), [_tripod, _player, _assembledClassname, _carryWeaponClassname], _onFinish, _onFailure, localize LSTRING(AssembleCSW_progressBar), _codeCheck] call EFUNC(common,progressBar);
}, _this] call CBA_fnc_execNextFrame;
