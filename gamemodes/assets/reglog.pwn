#include <ysilib\YSI_Coding\y_hooks>

static stock const USER_PATH[64] = "/Users/%s.ini";

const MAX_PASSWORD_LENGTH = 64;
const MIN_PASSWORD_LENGTH = 6;
const MAX_LOGIN_ATTEMPTS = 	3;

enum
{
	e_SPAWN_TYPE_REGISTER = 1,
    e_SPAWN_TYPE_LOGIN
};

static  
    player_Password[MAX_PLAYERS][MAX_PASSWORD_LENGTH],
    player_Sex[MAX_PLAYERS][2],
    player_Score[MAX_PLAYERS],
	player_Skin[MAX_PLAYERS],
    player_Money[MAX_PLAYERS],
    player_Ages[MAX_PLAYERS],
    player_LoginAttempts[MAX_PLAYERS];

forward Account_Load(const playerid, const string: name[], const string: value[]);
public Account_Load(const playerid, const string: name[], const string: value[])
{
	INI_String("Password", player_Password[playerid]);
	INI_String("Sex", player_Sex[playerid]);
	INI_Int("Level", player_Score[playerid]);
	INI_Int("Skin", player_Skin[playerid]);
	INI_Int("Money", player_Money[playerid]);

	return 1;
}

stock Account_Path(const playerid)
{
	new tmp_fmt[64];
	format(tmp_fmt, sizeof(tmp_fmt), USER_PATH, ReturnPlayerName(playerid));

	return tmp_fmt;
}

stock emptyline(const playerid, lines) {

    for(new i = 0; i < lines; i++) {
        SendClientMessage(playerid, -1, "");
    }
    return 1;
}

hook OnGameModeInit() {

    print("assets/reglog.pwn loading...");
    print("assets/reglog.pwn loaded.");
    
    return 1;

}

hook OnPlayerConnect(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	SetPlayerColor(playerid, x_white);
    emptyline(playerid, 20);

	if (fexist(Account_Path(playerid)))
	{
		INI_ParseFile(Account_Path(playerid), "Account_Load", true, true, playerid);
		Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
			"Prijavljivanje",
			"%s, unesite Vasu tacnu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);

		return 1;
	}

	Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
		"Registracija",
		"%s, unesite Vasu zeljenu lozinku: ",
		"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
	);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	new INI:File = INI_Open(Account_Path(playerid));
    INI_SetTag(File,"data");
    INI_WriteInt(File, "Level",GetPlayerScore(playerid));
    INI_WriteInt(File, "Skin",GetPlayerSkin(playerid));
    INI_WriteInt(File, "Money", GetPlayerMoney(playerid));
    INI_Close(File);

	return 1;
}

timer Spawn_Player[100](playerid, type)
{
	if (type == e_SPAWN_TYPE_REGISTER)
		{
            emptyline(playerid, 20);
			SendClientMessage(playerid, -1, ""c_server"aurora // "c_white"Uspesno ste se registrovali!");
			SetSpawnInfo(playerid, 0, player_Skin[playerid],
				154.2401,-1942.5531,3.7734,0.4520,
				0, 0, 0, 0, 0, 0
			);
			SpawnPlayer(playerid);

			SetPlayerScore(playerid, player_Score[playerid]);
			GivePlayerMoney(playerid, player_Money[playerid]);
			SetPlayerSkin(playerid, player_Skin[playerid]);
		}

		else if (type == e_SPAWN_TYPE_LOGIN)
		{
            emptyline(playerid, 20);
			SendClientMessage(playerid, x_server,"aurora // "c_white"Uspesno ste se prijavili!");
			SetSpawnInfo(playerid, 0, player_Skin[playerid],
				154.2401,-1942.5531,3.7734,0.4520,
				0, 0, 0, 0, 0, 0
			);
			SpawnPlayer(playerid);

			SetPlayerScore(playerid, player_Score[playerid]);
			GivePlayerMoney(playerid, player_Money[playerid]);
			SetPlayerSkin(playerid, player_Skin[playerid]);
		}

}

Dialog: dialog_regpassword(playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH))
		return Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
			"Registracija",
			"%s, unesite Vasu zeljenu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);

	strcopy(player_Password[playerid], inputtext);

	Dialog_Show(playerid, "dialog_regages", DIALOG_STYLE_INPUT,
		"Godine",
		"Koliko imate godina: ",
		"Unesi", "Izlaz"
	);

	return 1;
}

Dialog: dialog_regages(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!(12 <= strval(inputtext) <= 50))
		return Dialog_Show(playerid, "dialog_regages", DIALOG_STYLE_INPUT,
			"Godine",
			"Koliko imate godina: ",
			"Unesi", "Izlaz"
		);

	player_Ages[playerid] = strval(inputtext);

	Dialog_Show(playerid, "dialog_regsex", DIALOG_STYLE_LIST,
	"Spol",
	"Musko\nZensko",
	"Odaberi", "Izlaz"
	);

	return 1;
}

Dialog: dialog_regsex(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	new tmp_int = listitem + 1;

	new INI:File = INI_Open(Account_Path(playerid));
	INI_SetTag(File,"data");
	INI_WriteString(File, "Password", player_Password[playerid]);
	INI_WriteString(File, "Sex", (tmp_int == 1 ? ("Musko") : ("Zensko")));
	INI_WriteInt(File, "Age", player_Ages[playerid]);
	INI_WriteInt(File, "Level", 3);
	INI_WriteInt(File, "Skin", 240);
	INI_WriteInt(File, "Money", 25000);
	INI_WriteInt(File, "Admin", 0);
	INI_WriteInt(File, "AdminDuty", 0);
    INI_WriteInt(File, "Helper", 0);
	INI_WriteInt(File, "HelperDuty", 0);
	INI_WriteInt(File, "Promoter", 0);
	INI_Close(File);

	player_Money[playerid] = 25000;
	player_Skin[playerid] = 240;
	player_Score[playerid] = 3;

	defer Spawn_Player(playerid, 1);
	
	return 1;
}

Dialog: dialog_login(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!strcmp(player_Password[playerid], inputtext, false))
		defer Spawn_Player(playerid, 2);
	else
	{
		if (player_LoginAttempts[playerid] == MAX_LOGIN_ATTEMPTS)
			return Kick(playerid);

		++player_LoginAttempts[playerid];
		Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
			"Prijavljivanje",
			"%s, unesite Vasu tacnu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);
	}

	return 1;
}