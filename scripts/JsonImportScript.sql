/*
This script imports the various JSON data files from the POE-TradeMacro into the database tables
*/

DECLARE @JSON NVARCHAR(MAX)

--Armours
SELECT @JSON = BulkColumn
 FROM OPENROWSET (BULK '/home/ubuntu/POE-TradeMacro/data_trade/item_bases_armour.json', SINGLE_CLOB) as j


	IF ISJSON(@JSON) = 1
	BEGIN
	;WITH Items AS (
		SELECT [Key], [Value], [Type]
		FROM OPENJSON (@JSON, '$.item_bases_armour')
	)
	INSERT INTO dbo.ItemType (
		[Name],
		ItemClass,
		EnergyShield,
		Armour,
		EvasionRating,
		[Block],
		Intelligence,
		Strength,
		Dexterity,
		[Level],
		DropLevel,
		Width,
		Height)
	SELECT 
		PivotTable.[Name],
		[Item Class],
		[Energy Shield],
		[Armour],
		[Evasion Rating],
		[Block],
		[Intelligence],
		[Strength],
		[Dexterity],
		[Level],
		[Drop Level],
		[Width],
		[Height]
	FROM (	SELECT I.[Key] AS [Name], J.[Key] AS Attribute, J.[Value] AS [Value]
			FROM Items I
				CROSS APPLY OPENJSON(I.[Value]) J) AS SourceTable
	PIVOT
	(
		MAX(SourceTable.[Value])
		FOR Attribute IN([Item Class],[Energy Shield],[Armour],[Evasion Rating],[Block],[Intelligence],[Strength],[Dexterity],[Level],[Drop Level],[Width],[Height])
		) AS PivotTable
END



--Weapons
SELECT @JSON = BulkColumn
 FROM OPENROWSET (BULK '/home/ubuntu/POE-TradeMacro/data_trade/item_bases_weapon.json', SINGLE_CLOB) as j


IF ISJSON(@JSON) = 1
BEGIN
	;WITH Items AS (
		SELECT [Key], [Value], [Type]
		FROM OPENJSON (@JSON, '$.item_bases_weapon')
	)
	INSERT INTO dbo.ItemType (
		[Name],
		ItemClass,
		Intelligence,
		Strength,
		Dexterity,
		AttackSpeed,
		CriticalStrikeChance,
		MinPhysicalDamage,
		MaxPhysicalDamage,
		[Level],
		DropLevel,
		Width,
		Height)
	SELECT 
		PivotTable.[Name],
		[Item Class],
		[Intelligence],
		[Strength],
		[Dexterity],
		[Attack Speed],
		[Critical Strike Chance],
		[Minimum Physical Damage],
		[Maximum Physical Damage],
		[Level],
		[Drop Level],
		[Width],
		[Height]
	FROM (	SELECT I.[Key] AS [Name], J.[Key] AS Attribute, J.[Value] AS [Value]
			FROM Items I
				CROSS APPLY OPENJSON(I.[Value]) J) AS SourceTable
	PIVOT
	(
		MAX(SourceTable.[Value])
		FOR Attribute IN([Strength],[Maximum Physical Damage],[Item Class],[Critical Strike Chance],[Intelligence],[Drop Level],[Attack Speed],[Level],[Minimum Physical Damage],[Width],[Height],[Dexterity])
		) AS PivotTable
END