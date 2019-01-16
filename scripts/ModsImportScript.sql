DECLARE @JSON NVARCHAR(MAX)

--Armours
SELECT @JSON = BulkColumn
 FROM OPENROWSET (BULK '/home/ubuntu/poe-logger/data/mods.json', SINGLE_CLOB) AS j

IF ISJSON(@JSON) = 1
BEGIN
	IF OBJECT_ID('TempDb..#JSON') IS NOT NULL DROP TABLE #JSON
	CREATE TABLE #JSON (
		Element_ID INT, /* internal surrogate primary key gives the order of parsing and the list order */
		SequenceNo INT NULL, /* the sequence number in a list */
		Parent_ID INT, /* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
		Object_ID INT, /* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
		Name NVARCHAR(2000), /* the name of the object */
		StringValue NVARCHAR(MAX) NOT NULL, /*the string representation of the value of the element. */
		ValueType VARCHAR(10) NOT NULL /* the declared type of the value represented as a string in StringValue*/
	)

	INSERT INTO #JSON
	(
	    Element_ID,
	    SequenceNo,
	    Parent_ID,
	    Object_ID,
	    Name,
	    StringValue,
	    ValueType
	)
	SELECT Element_ID,
           SequenceNo,
           Parent_ID,
           Object_ID,
           Name,
           StringValue,
           ValueType
	FROM dbo.HierarchyFromJSON(@JSON)
	ORDER BY Element_ID 


	--DROP TABLE dbo.[Mod], modstat, modweight, dbo.ModGenerationWeights, dbo.ModAddsTag

	CREATE TABLE dbo.[Mod] (
		ModID INT,
		[Name] NVARCHAR(100),
		Domain NVARCHAR(100),
		GenerationType NVARCHAR(100),
		GrantsBuff NVARCHAR(100),
		GrantsEffect NVARCHAR(100),
		[Group] NVARCHAR(100),
		IsEssenceOnly BIT,
		AffixPrefixName NVARCHAR(100),
		RequiredLevel INT
	)

	CREATE TABLE dbo.ModStat (
		ModID INT,
		StringID NVARCHAR(200),
		[Min] INT,
		[Max] INT
		
	)
	
	CREATE TABLE dbo.ModWeight (
		ModID INT,
		Tag NVARCHAR(200),
		[Weight] INT
	)

	CREATE TABLE dbo.ModGenerationWeights (
		ModID INT,
		Tag NVARCHAR(200),
		[Weight] INT
	)

	CREATE TABLE dbo.ModAddsTag (
		ModID INT,
		Tag NVARCHAR(100)
	)


	INSERT INTO dbo.[Mod]
	(
	    ModID,
	    Name,
	    Domain,
	    GenerationType,
	    GrantsBuff,
	    GrantsEffect,
	    [Group],
	    IsEssenceOnly,
	    AffixPrefixName,
	    RequiredLevel
	)
	SELECT J1.Object_ID AS ModID, -- ModID - int
		J1.[Name], -- Name - nvarchar(100)
		NULLIF(MIN(CASE WHEN J2.Name = 'Domain' THEN J2.StringValue END),''),  -- Domain - nvarchar(100)
		NULLIF(MAX(CASE WHEN J2.Name = 'Generation_Type' THEN J2.StringValue END),''),  -- GenerationType - nvarchar(100)
		NULLIF(MAX(CASE WHEN J2.Name = 'grants_buff' THEN J2.StringValue END),''),  -- GrantsBuff - nvarchar(100)
		NULLIF(MAX(CASE WHEN J2.Name = 'grants_effect' THEN J2.StringValue END),''),  -- GrantsEffect - nvarchar(100)
		NULLIF(MAX(CASE WHEN J2.Name = 'group' THEN J2.StringValue END),''),  -- Group - nvarchar(100)
		CASE WHEN (MAX(CASE WHEN J2.Name = 'is_essence_only' THEN J2.StringValue END)) = 'False' THEN 0 ELSE 1 END, -- IsEssenceOnly - bit
		NULLIF(MAX(CASE WHEN J2.Name = 'name' THEN J2.StringValue END),''),  -- AffixPrefixName - nvarchar(100)
		NULLIF(MAX(CASE WHEN J2.Name = 'required_level' THEN J2.StringValue END),'')  -- RequiredLevel - int
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
	WHERE J1.Parent_ID = 0
	GROUP BY J1.Object_ID, J1.[Name]


	INSERT INTO dbo.ModStat
	(
	    ModID,
	    StringID,
	    [Max],
	    [Min]
	)
	SELECT
		J1.Object_ID,  -- ModID - int
		MAX(CASE WHEN J4.Name = 'id' THEN J4.StringValue END), -- StringID - nvarchar(200)
		MAX(CASE WHEN J4.Name = 'max' THEN J4.StringValue END), -- Max - int
		MAX(CASE WHEN J4.Name = 'min' THEN J4.StringValue END) -- Min - int
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
		LEFT JOIN #JSON J4 ON J4.Parent_ID = J3.Object_ID
	WHERE J1.Parent_ID = 0
		AND J2.[Name] LIKE '%stats%'
	GROUP BY J1.Object_ID

	INSERT INTO dbo.ModWeight
	(
	    ModID,
	    Tag,
	    Weight
	)
	SELECT
		J1.Object_ID, -- ModID - int
		MAX(CASE WHEN J4.Name = 'Tag' THEN J4.StringValue END), -- Tag - nvarchar(200)
		MAX(CASE WHEN J4.Name = 'Weight' THEN J4.StringValue END) -- Weight - int
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
		LEFT JOIN #JSON J4 ON J4.Parent_ID = J3.Object_ID
	WHERE J1.Parent_ID = 0
		AND	J2.Name = 'spawn_weights'
	GROUP BY J1.Object_ID, J3.Object_ID


	INSERT INTO dbo.ModGenerationWeights
	(
	    ModID,
	    Tag,
	    [Weight]
	)
	SELECT
	    J1.Object_ID,   -- ModID - int
	    MAX(CASE WHEN J4.Name = 'Tag' THEN J4.StringValue END), -- Tag - nvarchar(200)
	    MAX(CASE WHEN J4.Name = 'Weight' THEN J4.StringValue END)    -- Weight - int
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
		LEFT JOIN #JSON J4 ON J4.Parent_ID = J3.Object_ID
	WHERE J1.Parent_ID = 0
		AND J2.Name = 'generation_weights'
	GROUP BY J1.Object_ID, J3.Object_ID
	HAVING MAX(CASE WHEN J4.Name = 'Tag' THEN J4.StringValue END) IS NOT NULL
		OR MAX(CASE WHEN J4.Name = 'Weight' THEN J4.StringValue END) IS NOT NULL
	ORDER BY J1.Object_ID, J3.Object_ID


	INSERT INTO dbo.ModAddsTag
	(
	    ModID,
		Tag
	)
	SELECT
		J1.Object_ID,
		J3.StringValue
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
		LEFT JOIN #JSON J4 ON J4.Parent_ID = J3.Object_ID
	WHERE J1.Parent_ID = 0
		AND J2.Name = 'adds_tags'
		AND J3.StringValue IS NOT NULL	
	ORDER BY J1.Object_ID



END