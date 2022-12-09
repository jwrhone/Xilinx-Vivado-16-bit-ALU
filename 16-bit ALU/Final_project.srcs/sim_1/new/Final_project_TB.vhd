library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity Final_project_TB is
end Final_project_TB;

architecture Behavioral of Final_project_TB is
component ALU
                                                -- Moving all modules from ALU file and restating them in TestBench.
Port(
A,B : in std_logic_vector(15 downto 0);
OpCode : in std_logic_vector(2 downto 0);
Mode : in std_logic;
ALU_Out : out std_logic_vector(15 downto 0);
Cout : out std_logic);
    
end component;

component Controller is

Port(
Mode : in std_logic;
OpCode : in std_logic_vector(2 downto 0);
direction : out std_logic;
T : out std_logic;
opco : out std_logic_vector(2 downto 0);
Sel0 : out std_logic_vector(1 downto 0);
Sel1,Sel2,SelOut : out std_logic);
end component;

component Arithmetic_Unit is

Port(
A,B : in std_logic_vector(15 downto 0);
Sel0 : in std_logic_vector(1 downto 0);
Out1 : out std_logic_vector(15 downto 0);
CarryOut : out std_logic);
end component;

component Shifter_Unit is

Port(
A,B : in std_logic_vector(15 downto 0);
direction : in std_logic;
T: in std_logic;
Out2 : out std_logic_vector(15 downto 0));
end component;

component Logic_Unit is 

Port(
A,B : in std_logic_vector(15 downto 0);
OpCode : in std_logic_vector(2 downto 0);
Out3 : out std_logic_vector(15 downto 0));
end component;

component Mux is

Port(
S : in std_logic;
X,Y : in std_logic_vector(15 downto 0);
Z : out std_logic_vector(15 downto 0));
end component;

component gate is

Port(
    Input_A,Input_B : in std_logic;
    Out4 : out std_logic);
end component;

--Initial ALU Inputs:
signal A,B : std_logic_vector(15 downto 0);
signal OpCode : std_logic_vector(2 downto 0);
signal Mode : std_logic;

-- Controller Outputs:
signal Direction : std_logic;
signal T: std_logic; --Type
signal Sel_zero : std_logic_vector(1 downto 0);
signal Sel_one,Sel_two,Sel_Cout : std_logic;
signal opco : std_logic_vector(2 downto 0);

-- Arithmetic, Shifter, Logic, and MUX outputs:
signal Arith_out,Shift_out,Logic_out,Mux_out: std_logic_vector(15 downto 0);
signal AU_Cout : std_logic;

-- ALU Outputs:
signal ALU_Out : std_logic_vector(15 downto 0);
signal Cout : std_logic;

-- Arithmetic Multiplication special signals:
signal Amul : std_logic_vector(7 downto 0);
signal Bmul : std_logic_vector(7 downto 0);

begin

Amul <= A(7 downto 0);  -- Defining Amul and Bmul to the first 8 LSBs of input A and input B
Bmul <= B(7 downto 0);

-- Restating Module port maps
                    
Control: Controller port map(
                            Mode => Mode, OpCode => OpCode, direction => Direction, T => T, opco => opco, Sel0 => Sel_zero, Sel1 => Sel_one, Sel2 => Sel_two, SelOut => Sel_Cout);
LU: Logic_Unit port map(
                        A => A, B => B, OpCode => opco, Out3 => Logic_out);
SU: Shifter_Unit port map(
                         A => A, B => B, direction => Direction, T => T, Out2 => Shift_out);
AU: Arithmetic_Unit port map(
                            A => A, B => B, Sel0 => Sel_zero, Out1 => Arith_out, CarryOut => AU_Cout);
Mux1: Mux port map(
                  S => Sel_one, X => Arith_out, Y => Shift_out, Z => Mux_out);
Mux2: Mux port map(
                  S => Sel_two, X => Mux_out, Y => Logic_out, Z => ALU_Out);
GA: gate port map(
                    Input_A => AU_Cout, Input_B => Sel_Cout, Out4 => Cout);
 
process
begin
wait for 10 ns;
Mode <= '0';          -- Beginning Test Case with Mode set to 0 so that the Logic Unit outputs will be performed first.
OpCode <= "000";
A <= x"0001";
B <= x"0010";
wait for 10 ns;

OpCode <= "001";
wait for 10 ns;

OpCode <= "010";
wait for 10 ns;

OpCode <= "011";
wait for 10 ns;

OpCode <= "100";
wait for 10 ns;

OpCode <= "101";
wait for 10 ns;

OpCode <= "110";
wait for 10 ns;

OpCode <= "111";
wait for 10 ns;

Mode <= '1';                 -- Setting Mode to 1 so the Arithmetic and Shifter Unit outputs will be performed.
OpCode <= "000";
wait for 10 ns;

OpCode <= "001";
wait for 10 ns;

OpCode <= "010";
wait for 10 ns;

A <= x"FFFF";             -- Setting input A to "FFFF" so that the increment special case will be performed and Cout will be assigned 1
OpCode <= "011";
wait for 10 ns;

A <= x"0100";             -- Changing values of Input A and Input B so that the shifting and rotating operations will easier to visualize
B <= x"0001";
OpCode <= "100";
wait for 10 ns;

OpCode <= "101";
wait for 10 ns;

OpCode <= "110";
wait for 10 ns;

OpCode <= "111";
wait for 10 ns;



end process;
end Behavioral;
