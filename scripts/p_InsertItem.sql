CREATE OR ALTER PROCEDURE p_InsertItem
	@ItemLevel INT,
	@ItemType NVARCHAR(200),
	@Rarity NVARCHAR(200),
	@Quality INT = 0,
	@Elder BIT = NULL,
	@Shaper BIT = NULL,
	@Sockets NVARCHAR(100),
	@UserID INT = -1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.Item
	(
	    ItemLevel,
	    ItemType,
	    Rarity,
	    Quality,
	    Elder,
	    Shaper,
	    Sockets,
	    CreatedUserID
	)
	VALUES
	(   @ItemLevel,    -- ItemLevel - int
	    @ItemType,  -- ItemType - nvarchar(200)
	    @Rarity,  -- Rarity - nvarchar(200)
	    @Quality,    -- Quality - int
	    @Elder, -- Elder - bit
	    @Shaper, -- Shaper - bit
	    @Sockets,  -- Sockets - nvarchar(100)
	    @UserID     -- CreatedUserID - int
	    )

	SELECT SCOPE_IDENTITY() AS ItemID

END