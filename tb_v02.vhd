----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.11.2016 19:57:45
-- Design Name: 
-- Module Name: tb_v02 - Behavioral
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


library WORK;
use WORK.VGA_PKG.ALL; 
use WORK.DCSE_PKG.ALL;
use WORK.IMG_PKG.ALL; 
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;

entity tb_v02 is
--  Port ( );
end tb_v02;

architecture Behavior of tb_v02 is

Component TOPsp
    Port ( clk : in STD_LOGIC;
         rst : in STD_lOGIC;
         red : out STD_LOGIC_VECTOR (c_nb_red-1 downto 0);
         blue : out STD_LOGIC_VECTOR (c_nb_blue-1 downto 0);
         green : out STD_LOGIC_VECTOR (c_nb_green-1 downto 0);         
         vsynch : out STD_LOGIC;
         hsynch : out STD_LOGIC);  

end component;

--Inputs
    signal clk: STD_LOGIC := '0';
    signal rst: STD_LOGIC := c_off;
    
--Outputs
    signal red : STD_LOGIC_VECTOR (c_nb_red-1 downto 0);
    signal blue : STD_LOGIC_VECTOR (c_nb_blue-1 downto 0);
    signal green : STD_LOGIC_VECTOR (c_nb_green-1 downto 0);  
    signal vsynch : STD_LOGIC;
    signal hsynch : STD_LOGIC;

    
begin

TOP: TOPsp port map(
        clk => clk,
        rst => rst,
        red => red,
        green => green,
        vsynch => vsynch,
        hsynch => hsynch
        );
        
    -- Proceso de reloj        
        P_clk: Process
        begin
            clk <= '0';
                wait for (c_period_ns_clk/2)*1 ns;
            clk <= '1';
                wait for (c_period_ns_clk/2)*1 ns;
        end Process;
        
        -- Proceso de reset
        P_rst: Process
        begin
            rst <= c_off;
                wait for 100 ns;
            rst <= c_on;
                wait for 100 ns;
            rst <= c_off;
                wait; -- Cuando el reset esta apagado espera hasta que se vuelva a activar
        end Process;
    
--        P_estimulos: Process
--        begin
--       -- addr2 <= (others => '0');
--        -- Esperar a que haya un cambio en el valor reset y reset se ponga activo
--        wait until rst'event and (rst = c_on);   
--        -- Esperar a que reset se vuelva a poner inactivo
--        wait until rst = c_off;
--        -- Esperar 70 ns
--        wait;
--        end process;


end Behavior;
