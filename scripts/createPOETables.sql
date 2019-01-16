CREATE TABLE dbo.Item (
	ItemID INT IDENTITY(1,1) NOT NULL,
	ItemLevel INT NULL,
	ItemType NVARCHAR(200) NULL,
	ItemName NVARCHAR(300) NULL,
	Rarity NVARCHAR(200) NULL,
	Quality INT NULL,
	Elder BIT NULL,
	Shaper BIT NULL,
	Corrupted BIT NULL,
	Sockets NVARCHAR(100) NULL,
	CreatedUserID INT NULL
)

CREATE TABLE dbo.ItemType (
	ItemTypeID INT IDENTITY(1,1) NOT NULL,
	[Name] NVARCHAR(100) NOT NULL,
	ItemClass NVARCHAR(100) NOT NULL,
	EnergyShield INT NULL,
	Armour INT NULL,
	EvasionRating INT NULL,
	[Block] INT NULL,
	Intelligence INT NULL,
	Strength INT NULL,
	Dexterity INT NULL,
	AttackSpeed DECIMAL(10,2) NULL,
	CriticalStrikeChance DECIMAL(10,2) NULL,
	MinPhysicalDamage INT NULL,
	MaxPhysicalDamage INT NULL,
	[Level] INT NULL,
	DropLevel INT NULL,
	Width INT NULL,
	Height INT NULL
)

CREATE TABLE dbo.[User] (
	UserID INT IDENTITY(1,1) NOT NULL,
	UserName NVARCHAR(100),
	Token NVARCHAR(30)
)

CREATE TABLE dbo.ItemModifier (
	ItemModifierID INT IDENTITY(1,1) NOT NULL,
	ItemID INT NOT NULL,
	ModifierID INT NOT NULL,
	MinValue INT,
	MaxValue INT
)
