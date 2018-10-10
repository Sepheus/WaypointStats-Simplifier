DB_CHAR = "TINYINT UNSIGNED"
DB_TINYINT = "TINYINT UNSIGNED"
DB_SMALLINT = "SMALLINT UNSIGNED"
DB_MEDIUMINT = "MEDIUMINT UNSIGNED"
DB_INT = "INTEGER UNSIGNED"
DB_BIGINT = "BIGINT UNSIGNED"
DB_TEXT = "TEXT"
DB_VARCHAR = "TEXT"
DB_NUM = "NUMERIC"
DB_BOOL = "BOOL" 
DB_DATETIME = "DATETIME"
DB_DATE = "DATE"
DB_BLOB = "BLOB"
DB_REAL = "REAL"
DB_FLOAT = "FLOAT"
DB_PRIMARY = " PRIMARY KEY"
DB_FOREIGN = " FOREIGN KEY"

META_TEAMS_TABLE = "metaTeams"
META_EMBLEMS_BG_TABLE = "metaEmblemsBG"
META_EMBLEMS_FG_TABLE = "metaEmblemsFG"
META_MEDAL_CLASSES_TABLE = "metaMedalClasses"
META_MEDAL_TIERS_TABLE = "metaMedalTiers"
META_MEDALS_TABLE = "metaMedals"
META_PLAYLISTS_TABLE = "metaPlaylists"
META_MAPS_TABLE = "metaMaps"
META_GAME_MODES_TABLE = "metaGameModes"
META_FACTIONS_TABLE = "metaFactions"
META_WEAPON_TYPES_TABLE = "metaWeaponClasses"
META_DAMAGE_TYPES_TABLE = "metaDamageTypes"
META_DAMAGE_CLASSES_TABLE = "metaDamageClasses"
META_GAME_BASE_VARIANTS_TABLE = "metaGameBaseVariants"


TABLE_MAP = {
	"TeamAppearanceMetadata" => META_TEAMS_TABLE,
	"EmblemBackgroundShapeMetadata" => META_EMBLEMS_BG_TABLE,
	"EmblemForegroundShapeMetadata" => META_EMBLEMS_FG_TABLE,
	"MedalTierMetadata" => META_MEDAL_TIERS_TABLE,
	"MedalClassMetadata" => META_MEDAL_CLASSES_TABLE,
	"MedalMetadata" => META_MEDALS_TABLE,
	"PlaylistMetadata" => META_PLAYLISTS_TABLE,
	"MapMetadata" => META_MAPS_TABLE,
	"GameModeMetadata" => META_GAME_MODES_TABLE,
	"FactionMetadata" => META_FACTIONS_TABLE,
	"WeaponTypeMetadata" => META_WEAPON_TYPES_TABLE,
	"DamageTypeMetadata" => META_DAMAGE_TYPES_TABLE,
	"DamageClassMetadata" => META_DAMAGE_CLASSES_TABLE,
	"GameBaseVariantMetadata" => META_GAME_BASE_VARIANTS_TABLE,
}

META_MAP = {
		"TeamAppearanceMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"BackgroundColorId" => DB_INT, 
			"BackgroundShapeId" => DB_TINYINT, 
			"ForegroundPrimaryColor" => DB_INT,
			"ForegroundSecondaryColor" => DB_INT,
			"ForegroundShapeId" => DB_TINYINT,
			"PrimaryRGB" => DB_INT,
			"PrimaryRGBA" => DB_INT,
			"SecondaryRGB" => DB_INT,
			"SecondaryRGBA" => DB_INT,
		},
		"EmblemBackgroundShapeMetadata" => {
			"Order" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
		},
		"EmblemForegroundShapeMetadata" => {
			"Order" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
		},
		"MedalTierMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"Description" => DB_TEXT, 
		},
		"MedalClassMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
		},
		"MedalMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"Description" => DB_TEXT,
			"ClassId" => DB_TINYINT,
			"TierId" => DB_TINYINT,
			"GameBaseVariantId" => DB_TINYINT,
		},
		"PlaylistMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Description" => DB_TEXT,
			"Name" => DB_TEXT,
			"IsFreeForAll" => DB_BOOL,
			"ModeId" => DB_TINYINT,
			"EffectiveOn" => DB_DATETIME,
			"EffectiveUntil" => DB_DATETIME,
			"MaxLocalPlayers" => DB_TINYINT,
			"MaxPartySize" => DB_TINYINT,
		},
		"MapMetadata" => {
			"Id" => DB_SMALLINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"Description" => DB_TEXT,
			"GameModeId" => DB_TINYINT,
		},
		"GameModeMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"Description" => DB_TEXT,
		},
		"FactionMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"Description" => DB_TEXT,
		},
		"WeaponTypeMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
		},
		"DamageTypeMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"Description" => DB_TEXT,
			"Range" => DB_TINYINT,
			"Power" => DB_TINYINT,
			"WeaponClassId" => DB_TINYINT,
			"ClassId" => DB_TINYINT,
			"FactionId" => DB_TINYINT,
		},
		"DamageClassMetadata" =>  {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
		},
		"GameBaseVariantMetadata" => {
			"Id" => DB_TINYINT + DB_PRIMARY,
			"Name" => DB_TEXT,
			"Description" => DB_TEXT,
			"FeaturedStatName" => DB_TEXT,
			"KDRelevant" => DB_BOOL,
		},

}