/*
TSQL Challenges 
https://web.archive.org/web/20170122174949/http://beyondrelational.com/puzzles/tsql/default.aspx

TSQL Challenge 59 - Playing Chess in TSQL – Part 2
https://web.archive.org/web/20150323074358/http://beyondrelational.com/puzzles/challenges/92/playing-chess-in-tsql-part-2.aspx

This is a continuation of the previous challenge where we generated a TSQL representation of a chess board filled with pieces based on input strings in Forsyth-Edwards Notation. This challenge invites you to perform a bit more complicated operation.
Your job is to generate a string using Forsyth-Edwards Notation which represents the final position of pieces after performing a series of moves from the original position.

Sample Data
Layout Table
GameID Layout
------ ---------------------------------------------------- 
	 1 rnbqk2r/ppppbppp/5n2/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR
Movement Table

Seq  GameID Movement
---  ------ --------
  1		  1 Pd2d3
  2       1 pa7a6
  3       1 Bc1g5
  4       1 pb7b5

Your job is to build a Forsyth-Edwards Notation string which represents this position of the board.

Expected Results
GameID Result
------ --------------------------------------------------------
     1 rnbqk2r/2ppbppp/p4n2/1p2p1B1/2B1P3/3P1Q2/PPP2PPP/RN2K1NR

Rules
See Algebraic Chess Notation for a basic understanding of how moves are recorded.
To avoid ambiguity, all movements will be recorded with complete reference of the source location and target location. For example, a White Bishop moving from “c1” to “g5” will be recorded as “Bc1g5”.
All movements will be valid moves.
There will be no captures, promotions or castling in this version of the challenge. The only change that will happen on the board is the change of position of various pieces. In the final position, the board will have the same number of pieces.
The following notation is used to identify pieces
Piece  White Black
------ ----- -----
Rook   R     r
Knight N     n
Bishop B     b
King   K     k
Queen  Q     q
Pawn   P     p
The results should be ordered by GameID

Restrictions
The solution should be a single query that starts with a "SELECT" or “;WITH”

*/


--Sample Script
--Use the TSQL Script given below to generate the source tables and fill them with sample data.

IF OBJECT_ID('TC59_Layout','U') IS NOT NULL BEGIN
	DROP TABLE TC59_Layout
END
GO

CREATE TABLE TC59_Layout(
	GameID INT,
	Layout VARCHAR(MAX)
)
GO

INSERT INTO TC59_Layout(GameID,Layout)
SELECT 1,'rnbqk2r/ppppbppp/5n2/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR' 

SELECT * FROM TC59_Layout

GO
IF OBJECT_ID('TC59_Movement','U') IS NOT NULL BEGIN
	DROP TABLE TC59_Movement
END
GO

CREATE TABLE TC59_Movement(
	Seq INT IDENTITY PRIMARY KEY,
	GameID INT,
	Movement VARCHAR(MAX)
)
GO

INSERT INTO TC59_Movement(GameID,Movement)
SELECT 1,'Pd2d3' UNION ALL
SELECT 1,'pa7a6' UNION ALL
SELECT 1,'Bc1g5' UNION ALL
SELECT 1,'pb7b5'

SELECT * FROM TC59_Movement

-- More complex data

IF OBJECT_ID('TC59_Layout','U') IS NOT NULL BEGIN
	DROP TABLE TC59_Layout
END
GO

CREATE TABLE TC59_Layout(
	GameID INT,
	Layout VARCHAR(MAX)
)
GO

INSERT INTO TC59_Layout(GameID,Layout)
SELECT 1,'rnbqk2r/ppppbppp/5n2/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR' union all
SELECT 2,'rnbqk2r/ppppbppp/5n2/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR' union all
SELECT 3,'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR' union all
SELECT 4,'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR' union all
SELECT 5,'r7/pppppppp/8/8/8/8/PPPPPPPP/R7' union all
SELECT 6,'r7/8/8/8/8/8/8/Q7' 
SELECT * FROM TC59_Layout

GO
IF OBJECT_ID('TC59_Movement','U') IS NOT NULL BEGIN
	DROP TABLE TC59_Movement
END
GO

CREATE TABLE TC59_Movement(
	Seq INT IDENTITY PRIMARY KEY,
	GameID INT,
	Movement VARCHAR(MAX)
)
GO

INSERT INTO TC59_Movement(GameID,Movement)
SELECT 1,'Pd2d3' UNION ALL
SELECT 1,'pa7a6' UNION ALL
SELECT 1,'Bc1g5' UNION ALL
SELECT 1,'pb7b5'UNION ALL

SELECT 2,'Pd2d3' UNION ALL
SELECT 2,'pa7a6' UNION ALL
SELECT 2,'Bc1g5' UNION ALL
SELECT 2,'pb7b5' union all

SELECT 4,'Pa2a3' UNION ALL
SELECT 4,'ph7h6' UNION ALL

SELECT 4,'Nb1c3' UNION ALL
SELECT 4,'ng8f6' UNION ALL


SELECT 4,'Pa3a4' UNION ALL
SELECT 4,'ph6h5' UNION ALL
SELECT 4,'Pa4a5' UNION ALL
SELECT 4,'ph5h4' --UNION ALL
go 
INSERT INTO TC59_Movement(GameID,Movement)
SELECT 6,'Qa1h1' UNION ALL
SELECT 6,'ra8h8' UNION ALL
SELECT 6,'Qh1a1' UNION ALL
SELECT 6,'rh8a8' --UNION ALL
go 10000


SELECT * FROM TC59_Movement

-- Solution by Leszek Gniadkowski

;with cte1 as
(
	select
		t.GameID
		,replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(
									replace(cast(t.Layout as varchar(8000)) collate Latin1_General_BIN,'/','')
										,'1',' ')
										,'2','  ')
									,'3','   ')
								,'4','    ')
							,'5','     ')
						,'6','      ')
					,'7','       ')
				,'8','        ') x
	from TC59_Layout t
)
,cte3 as
(
	select
		tm2.GameID
		,tm2.Seq
		,left(tm2.Movement,1) F
		,(ascii(substring(tm2.Movement,2,1)) % 32 - 1) + (substring(tm2.Movement,3,1) - 1) * 8 src
		,(ascii(substring(tm2.Movement,4,1)) % 32 - 1) + (substring(tm2.Movement,5,1) - 1) * 8 dst
	from 
	(
		select
			tm.GameID
			,tm.Seq
			,cast(tm.Movement as varchar(8000)) collate Latin1_General_BIN Movement
		from TC59_Movement tm
	) tm2
)
,cte4 as
(	
	select
		 x.GameID
		,0 Seq
		,substring(x.x, (7 - r.n) * 8 + c.n + 1, 1) F
		,r.n * 8 + c.n field
	from cte1 x
	cross join (VALUES(0),(1),(2),(3),(4),(5),(6),(7)) r(n)
	cross join (VALUES(0),(1),(2),(3),(4),(5),(6),(7)) c(n)
	
	union all

	select 
		c3.GameID
		,c3.Seq
		,' ' F
		,c3.src field
	from cte3 c3

	union all

	select 
		c3.GameID
		,c3.Seq
		,c3.F
		,c3.dst field
	from cte3 c3
)
,cte5 as
(
	select
		c4.GameID
		,c4.field
		,c4.F
		,row_number() over (partition by c4.GameID, c4.field order by c4.Seq desc) rn
	from cte4 c4
)
,cte6 as
(
	select
		c5.GameID
		,c5.field
		,c5.F
	from cte5 c5
	where c5.rn = 1
)
,cte7 as
(
	select
		 GameID
		 ,max(case when field=56 then F end)
		+ max(case when field=57 then F end)
		+ max(case when field=58 then F end)
		+ max(case when field=59 then F end)
		+ max(case when field=60 then F end)
		+ max(case when field=61 then F end)
		+ max(case when field=62 then F end)
		+ max(case when field=63 then F end)
		+ '/'
		+ max(case when field=48 then F end)
		+ max(case when field=49 then F end)
		+ max(case when field=50 then F end)
		+ max(case when field=51 then F end)
		+ max(case when field=52 then F end)
		+ max(case when field=53 then F end)
		+ max(case when field=54 then F end)
		+ max(case when field=55 then F end)
		+ '/'
		+ max(case when field=40 then F end)
		+ max(case when field=41 then F end)
		+ max(case when field=42 then F end)
		+ max(case when field=43 then F end)
		+ max(case when field=44 then F end)
		+ max(case when field=45 then F end)
		+ max(case when field=46 then F end)
		+ max(case when field=47 then F end)
		+ '/'
		+ max(case when field=32 then F end)
		+ max(case when field=33 then F end)
		+ max(case when field=34 then F end)
		+ max(case when field=35 then F end)
		+ max(case when field=36 then F end)
		+ max(case when field=37 then F end)
		+ max(case when field=38 then F end)
		+ max(case when field=39 then F end)
		+ '/'
		+ max(case when field=24 then F end)
		+ max(case when field=25 then F end)
		+ max(case when field=26 then F end)
		+ max(case when field=27 then F end)
		+ max(case when field=28 then F end)
		+ max(case when field=29 then F end)
		+ max(case when field=30 then F end)
		+ max(case when field=31 then F end)
		+ '/'
		+ max(case when field=16 then F end)
		+ max(case when field=17 then F end)
		+ max(case when field=18 then F end)
		+ max(case when field=19 then F end)
		+ max(case when field=20 then F end)
		+ max(case when field=21 then F end)
		+ max(case when field=22 then F end)
		+ max(case when field=23 then F end)
		+ '/'
		+ max(case when field=8 then F end)
		+ max(case when field=9 then F end)
		+ max(case when field=10 then F end)
		+ max(case when field=11 then F end)
		+ max(case when field=12 then F end)
		+ max(case when field=13 then F end)
		+ max(case when field=14 then F end)
		+ max(case when field=15 then F end)
		+ '/'
		+ max(case when field=0 then F end)
		+ max(case when field=1 then F end)
		+ max(case when field=2 then F end)
		+ max(case when field=3 then F end)
		+ max(case when field=4 then F end)
		+ max(case when field=5 then F end)
		+ max(case when field=6 then F end)
		+ max(case when field=7 then F end) r
	from cte6
	group by GameID
)
select 
	c7.GameID
	,replace(
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(c7.r,'        ','8')
									,'       ','7')
									,'      ','6')
							,'     ','5')
						,'    ','4')
					,'   ','3')
				,'  ','2')
			,' ','1') Result
from cte7 c7
order by c7.GameID       

