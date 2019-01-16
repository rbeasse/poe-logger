CREATE OR ALTER PROCEDURE p_ReadModifierIDByString 
	@ModifierString NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON

	SELECT TOP 1
		MS.ModifierID
	FROM dbo.ModifierString MS
	WHERE MS.String LIKE @ModifierString
END