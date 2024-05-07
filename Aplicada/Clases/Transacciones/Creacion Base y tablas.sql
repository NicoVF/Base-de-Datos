CREATE DATABASE [TCL];
GO

USE TCL
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[creditCard_info](
	[credit_card_nro] [bigint] NOT NULL,
	[city] [nvarchar](50) NULL,
	[credit_card_limit] [float] NULL,
 CONSTRAINT [PK_creditCard_info] PRIMARY KEY CLUSTERED 
(
	[credit_card_nro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE TCL
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Transaccion](
	[id_transaction] [int] NOT NULL,
	[credit_card_nro] [bigint] NOT NULL,
	[date] [datetime] NOT NULL,
	[transaction_amount] [float] NOT NULL,
	[id_transaction_Reversion] [int],
	[transaction_type] [char]  NOT NULL
 CONSTRAINT [PK_transaction] PRIMARY KEY CLUSTERED 
(
	[id_transaction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




-- INSERT
BEGIN TRANSACTION
Insert into creditCard_info
Values  (1280981422329509,'Dallas',6000);
commit;
BEGIN TRANSACTION
Insert into creditCard_info
Values  (9737219864179988,'Houston',16000);
commit;
BEGIN TRANSACTION
Insert into creditCard_info
Values  (4749889059323202,'Auburn',14000);
commit;
BEGIN TRANSACTION
Insert into creditCard_info
Values  (9591503562024072,'Orlando',18000);
commit;
