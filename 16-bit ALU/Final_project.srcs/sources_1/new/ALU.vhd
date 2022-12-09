library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity ALU is -- Top module for design

Port(
A,B : in std_logic_vector(15 downto 0); -- The two 16-bit ALU inputs
OpCode : in std_logic_vector(2 downto 0); -- The 3-bit ALU OpCode input
Mode : in std_logic;                        -- The 1-bit ALU Mode input
ALU_Out : out std_logic_vector(15 downto 0); -- The 16-bit ALU final output
Cout : out std_logic);                          -- The 1-bit ALU outputs signifying a carry overflow
    
end ALU;

architecture Behavioral of ALU is
component Controller is                         -- Defining the ALU's sub-modules: the controller unit, arithmetic unit, shifter unit, logic unit, the two MUXs and the AND gate.

Port(
Mode : in std_logic;                        -- Input for the ALU Mode input to be used together with Sel0 for the arithmetic unit and shifter unit
OpCode : in std_logic_vector(2 downto 0);   -- Input for the ALU OpCode input
direction : out std_logic;                  -- Direction output for the shifter unit direciton input
T : out std_logic;                           -- Type output for the shifter unit type input
opco : out std_logic_vector(2 downto 0);    -- OpCode output directly copied from ALU OpCode input to be used for the logic unit
Sel0 : out std_logic_vector(1 downto 0);    -- 2-bit select output for the arithmetic and shifter units
Sel1,Sel2,SelOut : out std_logic);           -- 1-bit select outputs: Sel1 and Sel2 to be used for the two MUXs and SelOut to be used for the AND gate
end component;

component Arithmetic_Unit is

Port(
A,B : in std_logic_vector(15 downto 0);     -- Inputs for the two 16-bit ALU inputs
Sel0 : in std_logic_vector(1 downto 0);     -- 2-bit controller select to signal calculations
Out1 : out std_logic_vector(15 downto 0);   -- 16-bit output after calculations are finished for inputs A and B
CarryOut : out std_logic);                   -- 1-bit signal that signifys if an overflow has occured during the incrementation calculation.
end component;

component Shifter_Unit is

Port(
A,B : in std_logic_vector(15 downto 0);     -- Inputs for the two 16-bit ALU inputs
direction : in std_logic;                       -- 1-bit signal that wll determine if shift/rotation will be left or right
T: in std_logic;                                -- 1-bit signal that will determine if a shift or roation will happen
Out2 : out std_logic_vector(15 downto 0));      -- 16-bit output after shift/rotation has finished for inputs A and B
end component;

component Logic_Unit is 

Port(
A,B : in std_logic_vector(15 downto 0);     -- Inputs for the two 16-bit ALU inputs
OpCode : in std_logic_vector(2 downto 0);   -- Controller OpCode that wil determine which logic operation will be performed
Out3 : out std_logic_vector(15 downto 0));  -- 16-bit output after logical operation is finished for inputs A and B
end component;

component Mux is

Port(
S : in std_logic;                           -- Select that will determine if output Z is assigned input X or input Y
X,Y : in std_logic_vector(15 downto 0);
Z : out std_logic_vector(15 downto 0));
end component;

component gate is

Port(
    Input_A,Input_B : in std_logic;        -- An AND gate module that will output 1 if Input_A and Input_B are 1
    Out4 : out std_logic);
end component;

-- Signals linking all modules inputs and outputs
signal Direction : std_logic;
signal T: std_logic;
signal Sel_zero : std_logic_vector(1 downto 0);
signal Sel_one,Sel_two,Sel_Cout : std_logic;
signal opco : std_logic_vector(2 downto 0);
signal Arith_out,Shift_out,Logic_out,Mux_out: std_logic_vector(15 downto 0);
signal AU_Cout : std_logic;


begin

-- port maps using above signals to link all modules together

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
                    
end Behavioral;

 --------------------------------------------------------------------------------------------------------------------------- From here down are the entities         
 ---------------------------------------------------------------------------------------------------------------------------   and architectures for the 
 ---------------------------------------------------------------------------------------------------------------------------    ALU's sub-modules stated above.       

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity Controller is
Port(
Mode : in std_logic;
OpCode : in std_logic_vector(2 downto 0);
direction : out std_logic;
T : out std_logic;
opco : out std_logic_vector(2 downto 0);
Sel0 : out std_logic_vector(1 downto 0);
Sel1,Sel2,SelOut : out std_logic);
end Controller;

architecture arch_Controller of Controller is
begin

opco <= OpCode;
process(Mode,OpCode)
begin                               -- If Mode is 1 then arithmetic and shifter units will be used 
                                    -- If the OpCode is between "000" to "011" then the 2-bit select will be active
                                    -- and the 1-bits selects for the MUXs will be assigned 0 so that the arithmetic output 
                                    -- will assigned to the ALU output
                                    -- If the OpCode is between "100" and "111" then the 2-bit select will not be active and
                                    -- and the 1st 1-bit select will assigned 1 and the second 1-bit select will remain 0
                                    -- so that the shifter output will be assigned to the ALU ouput.
                                    -- additionally depending on the OpCode the type and direction will change depending on which shift/rotate operation will be performed
if Mode = '1' then
    if OpCode = "000" then
                     Sel0 <= "00";
                     Sel1 <= '0';
                     Sel2 <= '0';
                     SelOut <= '1';
    elsif OpCode = "001" then 
                     Sel0 <= "01";
                     Sel1 <= '0';
                     Sel2 <= '0';
                     SelOut <= '1';
    elsif OpCode = "010" then 
                     Sel0 <= "10";
                     Sel1 <= '0';
                     Sel2 <= '0';
                     SelOut <= '1';
   elsif OpCode ="011" then 
                     Sel0 <= "11";
                     Sel1 <= '0';
                     Sel2 <= '0';
                     SelOut <= '1';
  elsif OpCode = "100" then 
                     direction <= '0';
                     T <= '0';
                     Sel1 <= '1';
                     Sel2 <= '0';
  elsif OpCode = "101" then 
                     direction <= '1';
                     T <= '0';
                     Sel1 <= '1';
                     Sel2 <= '0';
  elsif OpCode = "110" then 
                     direction <= '0';
                     T <= '1';
                     Sel1 <= '1';
                     Sel2 <= '0';
  elsif OpCode = "111" then  
                     direction <= '1';
                     T <= '1';
                     Sel1 <= '1';
                     Sel2 <= '0';
  end if;

else
if Mode = '0' then
                                                    -- If Mode is 0 then the logic unit will be enabled and will perform an operation depending on the current OpCode
                                                    -- and its output will be assigned to the ALU output. The arithmetic unit will not be used which is why SelOut is = 0.
                                                    -- Thus whatever is outputted to the first MUX doesn't matter, the only thing that matters is what is outputted to the 
                                                    -- second MUX. This is why Sel2 is always = 1 so that the logic unit output will always be assigned to the ALU output
    if OpCode = "000" then
                     Sel0 <= "00";
                     Sel1 <= '0';
                     Sel2 <= '1';
                     SelOut <= '0';
    elsif OpCode = "001" then 
                     Sel0 <= "01";
                     Sel1 <= '0';
                     Sel2 <= '1';
                     SelOut <= '0';
    elsif OpCode = "010" then 
                     Sel0 <= "10";
                     Sel1 <= '0';
                     Sel2 <= '1';
                     SelOut <= '0';
   elsif OpCode ="011" then 
                     Sel0 <= "11";
                     Sel1 <= '0';
                     Sel2 <= '1';
                     SelOut <= '0';
  elsif OpCode = "100" then 
                     direction <= '0';
                     T <= '0';
                     Sel1 <= '1';
                     Sel2 <= '1';
  elsif OpCode = "101" then 
                     direction <= '1';
                     T <= '0';
                     Sel1 <= '1';
                     Sel2 <= '1';
  elsif OpCode = "110" then 
                     direction <= '0';
                     T <= '1';
                     Sel1 <= '1';
                     Sel2 <= '1';
  elsif OpCode = "111" then  
                     direction <= '1';
                     T <= '1';
                     Sel1 <= '1';
                     Sel2 <= '1';
  end if;

end if;
end if;
end process;
end arch_Controller;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity Arithmetic_Unit is

Port(
A,B : in std_logic_vector(15 downto 0);
Sel0 : in std_logic_vector(1 downto 0);
Out1 : out std_logic_vector(15 downto 0);
CarryOut : out std_logic);
end Arithmetic_Unit;

architecture arch_Arithmetic_Unit of Arithmetic_Unit is

signal Amul : std_logic_vector(7 downto 0);             -- Two 8-bt signals that will take the first 8 LSBs of inputs A and B to be used 
signal Bmul : std_logic_vector(7 downto 0);              -- for the multiplication operation since the arithmetic output is only 16 bits

begin

Amul <= A(7 downto 0);
Bmul <= B(7 downto 0);

process(A,B,Sel0)
begin

if A = x"FFFF" then                                 -- Special case : if A = "FFFF" and is incremented then the final value will be "0000" thus 
    CarryOut <= '1';                                 -- the CarryOut flag must be enabled so that the ALU Cout output will show an overflow of 1
else
    CarryOut <= '0';
 end if;

if  Sel0 = "00" then
                 Out1 <= std_logic_vector((unsigned(Amul)) * (unsigned(Bmul))); -- Multiplying the 8 LSBs of input A and input B together to get a 16-bit output
elsif Sel0 = "01" then
                 Out1 <= A + B;                                                      -- Adding input A and B together
elsif Sel0 = "10" then
                 Out1 <= A - B;                                                       -- Subtracting input B from input A
elsif Sel0 = "11" then
                 Out1 <= std_logic_vector(unsigned(A) + 1);                       -- Incrementing input A by a value of 1

end if;

end process;
end arch_Arithmetic_Unit;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity Logic_Unit is 

Port(
A,B : in std_logic_vector(15 downto 0);
OpCode : in std_logic_vector(2 downto 0);
Out3 : out std_logic_vector(15 downto 0));
end Logic_Unit;

architecture arch_Logic_Unit of Logic_Unit is
begin

process (A,B,OpCode)
begin
                                                    -- Depending on OpCode input the logic unit output will be assigned its corresponding logic operation
    if OpCode = "000" then
                         Out3 <= A NOR B;
    elsif OpCode = "001" then 
                            Out3 <= A NAND B;
    elsif OpCode = "010" then 
                            Out3 <= A OR B;
    elsif OpCode = "011" then 
                            Out3 <= A AND B;
    elsif OpCode = "100" then 
                            Out3 <= A XOR B;
    elsif OpCode = "101" then 
                            Out3 <= A XNOR B;
    elsif OpCode = "110" then 
                            Out3 <= NOT A;
    elsif OpCode = "111" then 
                            Out3 <= NOT B;

end if;
end process;
end arch_Logic_Unit;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity Shifter_Unit is

Port(
A,B : in std_logic_vector(15 downto 0);
direction : in std_logic;
T: in std_logic;
Out2 : out std_logic_vector(15 downto 0));
end Shifter_Unit;

architecture arch_Shifter_Unit of Shifter_Unit is
begin

process(A,B,T, direction)
begin

if T = '1' then                                                                     -- If the 1-bit "type" input is 1 and the 1-bit "direction" input is 1 then Input A will be
    if direction = '1' then                                                         -- rotated right by the value of Input B, if "direction" input is 0 then Input A will be 
        Out2 <= std_logic_vector(unsigned(A) ror to_integer(unsigned(B)));     -- roated right by the value of Input B
    else
        Out2 <= std_logic_vector(unsigned(A) rol to_integer(unsigned(B)));
    end if;
 elsif T = '0' then                                                                 -- If the 1-bit "type" input is 0 and the 1-bit "direction" input is 1 then Input A will be
    if direction = '1' then                                                         -- shifted right be the value of Input B, if the "direction" input is 0 then Input A will be 
        Out2 <= std_logic_vector(unsigned(A) srl to_integer(unsigned(B)));    -- shifted left by the vlaue of Input B
    else 
        Out2 <= std_logic_vector(unsigned(A) sll to_integer(unsigned(B)));
    end if;
end if;
    

end process;
end arch_Shifter_Unit;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity Mux is

Port(
S : in std_logic;
X,Y : in std_logic_vector(15 downto 0);
Z : out std_logic_vector(15 downto 0));
end Mux;

architecture arch_Mux of Mux is
begin

process(S,X,Y)
begin

if S = '0' then
    Z <= X;             -- If select is = 0 then the Mux output is assigned the X input
else
    Z <= Y;             -- if the select is = 1 then the Mux output is assigned the Y input
end if;

end process;
end arch_Mux;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity gate is

Port(
    Input_A,Input_B : in std_logic;
    Out4 : out std_logic);
end gate;

architecture arch_gate of gate is
begin

Out4 <= Input_A AND Input_B;  -- The gates output is assigned 1 if Input_A and Input_B are both 1

end arch_gate;
