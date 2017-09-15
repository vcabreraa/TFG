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
    wea1 : in std_logic; --Señal que indica la escritura en la RAM (imagen procesada)
    addra : in std_logic_vector(c_dim_img-1 downto 0); --Dirección de memoria a escribir en la RAM. Direccion del pixel comparado que supera el umbral de parecido.
    addrb : in std_logic_vector(c_dim_img-1 downto 0); --Direccion de memoria para pintar la imagen procesada en la VGA
    dina : in std_logic; --Valor del pixel comparado que supera el umbral de parecido para escrbirlo en la RAM
    doutb : out std_logic --Valor del pixel para pintar la imagen procesada en la VGA
    );
end RAMsp;

architecture Behavioral of RAMsp is

signal addra_int, addrb_int : natural range 0 to 2**c_dim_img -1;
signal addra_rg_int, addrb_rg_int : natural range 0 to 2**c_dim_img -1;

type memostruct is array (natural range<>) of std_logic;
signal memo : memostruct(0 to 2**c_dim_img -1) := (others => '1');

begin

P_MUX: Process (wea1, addra)
begin
    if wea1 = '1' then --Señal que indica la escritura en la RAM
        addra_int <= TO_INTEGER(unsigned(addra));
    end if;
end process;

addrb_int <= TO_INTEGER(unsigned(addrb));

--------Proceso que primero escribe en a, y luego lee por b---------
P1: process (clk)
begin
    if clk'event and clk='1' then
        if wea1 = '1' then --Señal que indica la escritura en la RAM (en a)
             memo(addra_int) <= dina;
        end if;
           addra_rg_int <= addra_int;
           addrb_rg_int <= addrb_int;
    end if;
end process;
--------------------------------------------------------------------

doutb <= memo(addrb_rg_int);

end Behavioral;