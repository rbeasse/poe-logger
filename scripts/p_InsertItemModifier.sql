CREATE OR ALTER PROCEDURE p_InsertItemModifier
	@ModifierID INT,
	@ItemID INT,
	@ModifierTypeID INT,
	@MinValue INT,
	@MaxValue INT
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ItemModifier
	(
		ItemID,
		ModifierID,
		ModifierTypeID,
		MinValue,
		MaxValue
	)
	VALUES
	(   @ItemID, -- ItemID - int
		@ModifierID, -- ModifierID - int
		@ModifierTypeID, -- ModifierTypeID - int
		@MinValue, -- MinValue - int
		@MaxValue  -- MaxValue - int
		)

END