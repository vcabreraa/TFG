----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


library WORK;
use WORK.IMG_PKG.ALL; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAMsp is
port( 
    clk : in std_logic;
    wea : in std_logic;
    wea1 : in std_logic;
    addra : in std_logic_vector(c_2dim_img-1 downto 0);
    addr3 : in std_logic_vector(c_2dim_img-1 downto 0);
    addrb : in std_logic_vector(c_2dim_img-1 downto 0);
    dina : in std_logic_vector(8-1 downto 0);
--    douta : out std_logic_vector(8-1 downto 0);
    doutb : out std_logic_vector(8-1 downto 0)
    );
end RAMsp;

architecture Behavioral of RAMsp is

signal addra_int, addrb_int : natural range 0 to 2**c_2dim_img -1;
signal addra_rg_int, addrb_rg_int : natural range 0 to 2**c_2dim_img -1;

type memostruct is array (natural range<>) of std_logic_vector(8-1 downto 0);
signal memo : memostruct(0 to 2**c_2dim_img -1); --90000??


begin

P_MUX: Process (wea, wea1)
begin
    if wea1 = '1' then
        addra_int <= TO_INTEGER(unsigned(addra));
    elsif wea = '1' then
        addra_int <= TO_INTEGER(unsigned(addr3));
    end if;
end process;

addrb_int <= TO_INTEGER(unsigned(addrb));

P1: process (clk) --Primero escribe en a, luego lee por b.
begin
    if clk'event and clk='1' then
        if wea1 = '1' then -- si se escribe en a
             memo(addra_int) <= dina;
        elsif wea = '1' then
             memo(addra_int) <= (others => '1');
        end if;
           addra_rg_int <= addra_int;
           addrb_rg_int <= addrb_int;
    end if;
end process;

doutb <= memo(addrb_rg_int);
--douta <= memo(addra_rg_int);

end Behavioral;