SELECT
	CONVERT(DECIMAL(10,2), MW.Weight) / SUM(MW.Weight) OVER (PARTITION BY M.GenerationType) AS [Percentage],
	*
FROM dbo.ModWeight AS MW
	INNER JOIN dbo.Mod AS M ON M.ModID = MW.ModID
	INNER JOIN dbo.ModStat AS MS ON MS.ModID = M.ModID
WHERE 1=1
AND (M.Domain ='abyss_jewel' AND tag IN('abyss_jewel_ranged','default')
	OR MW.Tag IN('abyss_jewel', 'abyss_jewel_ranged'))
AND M.GenerationType <> 'Corrupted'
AND MW.Weight <> 0

SELECT *
FROM dbo.ModWeight AS MW
	INNER JOIN dbo.Mod AS M ON M.ModID = MW.ModID
	INNER JOIN dbo.ModStat AS MS ON MS.ModID = M.ModID
WHERE M.Domain ='abyss_jewel'
AND tag IN('abyss_jewel_ranged','default')
AND M.GenerationType = 'prefix'
AND MW.Weight <> 0
AND [group] LIKE '%life%'




SELECT *
FROM (	SELECT TOP 1 *
		FROM dbo.Item AS I
		ORDER BY I.ItemID DESC) I
	INNER JOIN dbo.ItemModifier AS IM ON IM.ItemID = I.ItemID
	INNER JOIN dbo.ModifierString AS MS ON MS.ModifierID = IM.ModifierID
