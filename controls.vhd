----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2024 02:01:33 PM
-- Design Name: 
-- Module Name: controls - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controls is
    Port (
        -- Timing signals 
        clk, en, rst : in std_logic;

        -- Register File IO 
        rID1, rID2 : out std_logic_vector(4 downto 0);
        wr_en1, wr_en2 : out std_logic;
        regrD1, regrD2  : in std_logic_vector(15 downto 0);
        regwD1, regwD2 : out std_logic_vector(15 downto 0);

        --Framebuffer IO 
        fbRST : out std_logic;
        fbAddr : out std_logic_vector(11 downto 0);
        fbDin1 : in std_logic_vector(15 downto 0);
        fbDout1 : out std_logic_vector(15 downto 0);
        fbWr_en : out std_logic;

        --Instruction memory IO 
        irAddr : out std_logic_vector(13 downto 0);
        irWord : in std_logic_vector(31 downto 0);

        -- Data memory IO 
        dAddr : out std_logic_vector(14 downto 0);
        d_wr_en : out std_logic;
        dOut : out std_logic_vector(15 downto 0);
        dIn : in std_logic_vector(15 downto 0);

        --ALU IO 
        aluA, aluB : out std_logic_vector(15 downto 0);
        aluOp : out std_logic_vector(3 downto 0);
        aluResult : in std_logic_vector(15 downto 0);

        --UART IO 
        ready, newChar : in std_logic;
        send : out std_logic;
        charRec : in std_logic_vector(7 downto 0);
        charSend : out std_logic_vector(7 downto 0));
end controls;

architecture Behavioral of controls is

    type state is (fetch, decode0, decode1, Rops, Iops, Jops, calc, calc1, store, jr, recv, rpix, wpix, snd, equals, nequal, ori, lw, lw2, sw, jmp, jal, clrscr, finish);
    signal PS : state := fetch;

    signal PC : std_logic_vector(15 downto 0);
    signal INSTRUCTION : std_logic_vector(31 downto 0);
    signal arg1, arg2, alu_result: std_logic_vector(15 downto 0);
    signal regResID : std_logic_vector(4 downto 0);
begin

    -- Define the FSM process
    FSM_Process : process(clk)
    begin
        if rst = '1' then
            -- Reset the FSM to the initial state
            PS <= fetch;
        elsif rising_edge(clk) then
            -- Define next state and output logic
            case PS is
                when fetch =>
                    rID1 <= "00001"; --Ask for program counter
                    PC <= regrD1; --Read it
                    PS <= decode0;
                when decode0 =>
                    irAddr <= PC(13 downto 0); --Ask for instruction
                    wr_en1 <= '1'; --Enable writing to line 1
                    rID1 <= "00001"; --Set register to program counter 
                    regwD1 <= std_logic_vector(unsigned(PC)+1); --Increment program counter by 1 and set the value of the register  
                    PS <= decode1;
                when decode1 =>
                    INSTRUCTION <= irWord; --Store instruction into signal
                    if(INSTRUCTION(31 downto 30) = "00" or INSTRUCTION(31 downto 30) = "01") then
                        PS <= Rops;
                    elsif(INSTRUCTION(31 downto 30) = "10") then
                        PS <= Iops;
                    else
                        PS <= Jops;
                    end if;
                when Rops =>
                    regResID <= INSTRUCTION(26 downto 22); --Store into
                    rID1 <= INSTRUCTION(21 downto 17); -- Argument 1
                    rID2 <= INSTRUCTION(16 downto 12); -- Argument 2
                    arg1 <= regrD1;
                    arg2 <= regrD2;
                    if(INSTRUCTION(31 downto 27) = "01101") then
                        PS <= jr;
                    elsif(INSTRUCTION(31 downto 27) = "01100") then
                        PS <= recv;
                    elsif(INSTRUCTION(31 downto 27) = "01111") then
                        PS <= rpix;
                    elsif(INSTRUCTION(31 downto 27) = "01110") then
                        PS <= wpix;
                    elsif(INSTRUCTION(31 downto 27) = "01011") then
                        PS <= snd;
                    else
                        PS <= calc;
                    end if;
                when Iops =>
                    regResID <= INSTRUCTION(26 downto 22); --Store into    
                    rID2 <= INSTRUCTION(21 downto 17); --Ask for arg 1 from register on line 2
                    arg1 <= regrD2; --Retrieve value for arg 1 from line 2
                    arg2 <= INSTRUCTION(16 downto 1);
                    if(INSTRUCTION(29 downto 27) = "000") then
                        PS <= equals;
                    elsif(INSTRUCTION(29 downto 27) = "001") then
                        PS <= ori;
                    elsif(INSTRUCTION(29 downto 27) = "011") then
                        PS <= lw;
                    else
                        PS <= sw;
                    end if;
                when Jops =>
                    arg1 <= INSTRUCTION(26 downto 11);
                    if(INSTRUCTION(31 downto 27) = "11000") then
                        PS <= jmp;
                    elsif(INSTRUCTION(31 downto 27) = "11001") then
                        PS <= jal;
                    else
                        PS <= clrscr;
                    end if;
                when calc =>
                    aluA <= arg1;
                    aluB <= arg2;
                    aluOp <= INSTRUCTION(31 downto 27);
                    PS <= calc1;--Wait for calculation
                when calc1 =>
                    alu_result <= aluResult;
                    PS <= store;
                when store=>
                    wr_en1 <= '1';
                    rID1 <= regResID;
                    regwD1 <= alu_result;
                    PS <= finish;
                when ori =>
                    alu_result<=arg1 or arg2;
                    PS<=store;
                when lw =>
                    dAddr<= std_logic_vector(unsigned(arg1) + unsigned(arg2));
                when lw2 =>
                    alu_result <= dIn;
                    PS <= store;
                when wpix=>
                    fbAddr <= arg1(11 downto 0);
                    fbWr_en <= '1';
                    fbDout1 <= arg2;
                    PS <= finish;
                when equals =>
                    rID1 <=regResID;
                    if(arg1=regrD1) then
                        alu_result<=arg2;
                        regResID <= PC;
                    end if;
                    PS<= store;
                when recv=>
                    alu_result <= charRec;
                    if(newChar = '1') then
                        PS <= recv;
                    else
                        PS <= store;
                    end if;
                when jmp=>
                    rID1 <= "00001";
                    wr_en1 <= '1';
                    regwD1 <= arg2; --Set value of PC register to immediate
                when snd=>
                    send <= '1';
                    rID1 <= regResID; --Request register 1 data
                    charSend <= regrD1; --Send reg 1 data 
                    if(ready = '1') then
                        PS <= finish;
                    else
                        PS <= snd;
                    end if;
                when finish=>
                    fbRST <= '0';
                    fbAddr <= (others => '0');
                    fbDout1 <= (others => '0');
                    fbWr_en <= '0';

                    regwD1 <= (others => '0');
                    regwD2 <= (others => '0');
                    wr_en1 <= '0';
                    wr_en2 <= '0';

                    dAddr <= (others => '0');
                    d_wr_en <= '0';

                    send <= '0';
                    charSend <= (others => '0');
                    
                    aluA <= (others => '0');
                    aluB <= (others => '0');
                    aluOp <= (others =>'0');
                    PS<= fetch;
                when others =>
                    PS <= fetch;
            end case;
        end if;
    end process FSM_Process;


end Behavioral;
