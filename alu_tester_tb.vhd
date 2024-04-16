----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2024 07:44:51 PM
-- Design Name: 
-- Module Name: alu_tester_tb - Behavioral
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

entity alu_tester_tb is
 -- Port ( );
end alu_tester_tb;

architecture Behavioral of alu_tester_tb is
    signal tb_clk : std_logic := '0';
    signal tb_btn, tb_op: std_logic_vector(3 downto 0):= (others=>'0');
    signal tb_sw : std_logic_vector(15 downto 0) := (others=>'0');
    signal tb_led : std_logic_vector(15 downto 0):= (others=>'0'); 
    component alu_tester is
        Port (clk : in std_logic;
                sw : in std_logic_vector(15 downto 0);
                btn, op: in std_logic_vector(3 downto 0);
                led: out std_logic_vector(15 downto 0));
    end component alu_tester;


begin

    clk_gen_proc: process
    begin

        wait for 4 ns;
        tb_clk <= '1';

        wait for 4 ns;
        tb_clk <= '0';

    end process clk_gen_proc;

    
    sw_gen: process
    begin

        wait for 8 ns;
        tb_sw <= std_logic_vector (unsigned(tb_sw)+1);

    end process sw_gen;

    btn_gen: process
    begin

        wait for 8 ns;
        tb_btn <= "0001";
        wait for 8 ns;
        tb_btn <= "0010";
        wait for 8 ns;
        tb_btn <= "0100";
        tb_op <= std_logic_vector(unsigned(tb_op) + 1);
        wait for 8 ns;
        tb_btn <= "1000";
    end process btn_gen;
    
    alu: alu_tester
        port map(
            clk=>tb_clk,
            btn=>tb_btn,
            sw=>tb_sw,
            op=>tb_op,
            led=>tb_led);

end Behavioral;