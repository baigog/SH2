library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY RS232_RX IS
	PORT(
		CLK:			IN	STD_LOGIC;
		RST:			IN	STD_LOGIC;
		RX:			IN	STD_LOGIC;
		FSEL:			IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
		
		DATA_OK:		OUT STD_LOGIC;
		DATAOUT:		OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
END RS232_RX;

ARCHITECTURE BEH OF RS232_RX IS

COMPONENT RS232_RX_FSM IS
	PORT(
		CLK:			IN	STD_LOGIC;
		RST:			IN	STD_LOGIC;
		TX:			IN	STD_LOGIC;
		
		SHIFT:			OUT	STD_LOGIC;
		DATA_OK:			OUT	STD_LOGIC
		);
END COMPONENT;

COMPONENT SHIFT_REGISTER_RX IS
GENERIC(
	data_width:	integer:=8
	);
PORT(
	CLK:				IN		STD_LOGIC;
	RST:				IN		STD_LOGIC;
	DATAIN:			IN		STD_LOGIC;
	SHIFT:			IN		STD_LOGIC;
	DATAOUT:			OUT	STD_LOGIC_VECTOR(data_width-1 DOWNTO 0)
);
END COMPONENT;

COMPONENT DATA_BUFFER IS
GENERIC(
			data_width:	integer:=8
		);
PORT(
	DATAIN:	IN		STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
	EN:		IN		STD_LOGIC;
	CLK:		IN		STD_LOGIC;
	CLEAR:	IN		STD_LOGIC;
	DATAOUT:	OUT	STD_LOGIC_VECTOR(data_width-1 DOWNTO 0)
	);
END COMPONENT;

SIGNAL DOK, SHIFT, PCHECK:				STD_LOGIC;
SIGNAL PBIT:										STD_LOGIC;
SIGNAL DATA_BUFF:									STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN


RX_FSM1: RS232_RX_FSM PORT MAP(	CLK=>CLK,
											RST=>RST,
											TX=>RX,
											SHIFT=>SHIFT,
											DATA_OK=>DOK);
					
SR1:	SHIFT_REGISTER_RX PORT MAP(	CLK=>CLK,
												RST=>RST,
												DATAIN=>RX,
												SHIFT=>SHIFT,
												DATAOUT=>DATA_BUFF);
												
													
DBUFFER:	DATA_BUFFER	PORT MAP(	DATAIN	=>	DATA_BUFF,
											EN			=>	DOK,
											CLK		=>	CLK,
											DATAOUT	=>	DATAOUT,
											CLEAR		=> '0');

PROCESS (CLK)
VARIABLE AUX:	STD_LOGIC;
BEGIN
	IF (RISING_EDGE(CLK)) THEN
		DATA_OK <= AUX;
		AUX := DOK;
	END IF;
END PROCESS;
END BEH;