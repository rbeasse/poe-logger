DECLARE @JSON NVARCHAR(MAX)

--Armours
SELECT @JSON = BulkColumn
 FROM OPENROWSET (BULK '/home/ubuntu/poe-logger/data/stat_translations.json', SINGLE_CLOB) AS j

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

	--DROP TABLE dbo.Modifier, dbo.ModifierID, dbo.ModifierString, dbo.ModifierStringFormat, dbo.ModifierStringIndexHandler

	CREATE TABLE dbo.Modifier (ModifierID INT)
	CREATE TABLE dbo.ModifierID (ModifierID INT, StringID NVARCHAR(200))
	CREATE TABLE dbo.ModifierString (ModifierStringID INT IDENTITY(1,1), ModifierID INT, String NVARCHAR(800), ConditionMIN INT, ConditionMAX INT)
	CREATE TABLE dbo.ModifierStringFormat(ModifierStringID INT, [Format] NVARCHAR(50), [Order] INT)
	CREATE TABLE dbo.ModifierStringIndexHandler(ModifierStringID INT, Handler NVARCHAR(100), [Order] INT)

	INSERT INTO dbo.Modifier
	(
	    ModifierID
	)
	SELECT DISTINCT J1.Object_ID
	FROM #JSON J1
	WHERE J1.Parent_ID = 0
	ORDER BY J1.Object_ID

	INSERT INTO dbo.ModifierID
	(
	    ModifierID,
	    StringID
	)
	SELECT
		J1.Object_ID,  -- ID - int
	    J3.StringValue -- StringID - nvarchar(200
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
	WHERE J1.Parent_ID = 0
		AND J2.Name = 'ids'
	ORDER BY J1.Object_ID

	INSERT INTO dbo.ModifierString
	(
	    ModifierID,
		String,
	    ConditionMIN,
	    ConditionMAX
	)
	SELECT
	    J1.Object_ID, -- ModifierID - int
		MIN(CASE WHEN J4.Name = 'String' THEN J4.StringValue ELSE NULL END), -- String - nvarchar
	    MIN(CASE WHEN J6.Name = 'min' THEN CONVERT(INT, J6.StringValue) ELSE NULL END), -- ConditionMIN - int
	    MAX(CASE WHEN J6.Name = 'max' THEN CONVERT(INT, J6.StringValue) ELSE NULL END)  -- ConditionMAX - int
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
		LEFT JOIN #JSON J4 ON J4.Parent_ID = J3.Object_ID
		LEFT JOIN #JSON J5 ON J5.Parent_ID = J4.Object_ID
		LEFT JOIN #JSON J6 ON J6.Parent_ID = J5.Object_ID
	WHERE J1.Parent_ID = 0
		AND J2.Name = 'English'
		AND J4.Name IN('Condition','String')
	GROUP BY J1.Object_ID, J3.Object_ID

	INSERT INTO dbo.ModifierStringFormat
	(
	    ModifierStringID,
	    Format,
	    [Order]
	)
	SELECT
		J3.Object_ID,   -- StringID - int
	    J5.StringValue, -- Format - nvarchar(50)
	    ROW_NUMBER() OVER(PARTITION BY J3.Object_ID ORDER BY J5.Object_ID) AS RowNum    -- Order - int
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
		LEFT JOIN #JSON J4 ON J4.Parent_ID = J3.Object_ID
		LEFT JOIN #JSON J5 ON J5.Parent_ID = J4.Object_ID
		LEFT JOIN #JSON J6 ON J6.Parent_ID = J5.Object_ID
	WHERE J1.Parent_ID = 0
		AND J2.Name = 'English'
		AND J4.Name = 'format'
	ORDER BY J1.Object_ID


	INSERT INTO dbo.ModifierStringIndexHandler
	(
	    ModifierStringID,
	    Handler,
	    [Order]
	)
	SELECT
	    J3.Object_ID,   -- StringID - int
	    J6.StringValue, -- Handler - nvarchar(100)
	    ROW_NUMBER() OVER(PARTITION BY J3.Object_ID ORDER BY J6.Object_ID) AS RowNum    -- Order - int		
	FROM #JSON J1
		LEFT JOIN #JSON J2 ON J2.Parent_ID = J1.Object_ID
		LEFT JOIN #JSON J3 ON J3.Parent_ID = J2.Object_ID
		LEFT JOIN #JSON J4 ON J4.Parent_ID = J3.Object_ID
		LEFT JOIN #JSON J5 ON J5.Parent_ID = J4.Object_ID
		LEFT JOIN #JSON J6 ON J6.Parent_ID = J5.Object_ID
	WHERE J1.Parent_ID = 0
	AND J1.Object_ID = 8
		AND J2.Name = 'English'
		AND J4.Name = 'index_handlers'
		AND J6.StringValue <> ''
	ORDER BY J1.Object_ID
	
	UPDATE dbo.ModifierString
	SET String = REPLACE(String,'%','')

END