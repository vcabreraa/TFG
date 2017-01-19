----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.IMG_PKG.ALL; 
use WORK.VGA_PKG.ALL; 
use WORK.DCSE_PKG.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PNEGsp is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           wea : out std_logic;
           dout2 : in STD_LOGIC;
           --fincuenta : out STD_LOGIC;
           addr2 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0); --Cambiado para poder el tb
           addr1 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
           addr3 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
           para_contador : in STD_LOGIC);
       --    compara : out STD_LOGIC); --Ahora sale de la maquina de estados cuando se detecta un pxl negro
end PNEGsp;

architecture Behavioral of PNEGsp is

--Señales para el contador de todos los píxeles de la imagen 2
 signal cuenta : unsigned (c_2dim_img - 1 downto 0); 
 constant  c_fin_cuenta : natural := dim_img - 1;

 

 signal addr2_aux : STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);

begin

--Contador de todos los píxeles de la imagen 2
P_CONT_IMG2: Process (rst, clk)
begin

    if rst = c_on then
        cuenta <= (others => '0');
        wea <= '0';
        --fincuenta <= '0';
    elsif clk'event and clk = '1' then
       -- fincuenta <= '0';
        wea <= '0';
        if cuenta = c_fin_cuenta then
            wea <= '1';
            cuenta <= (others => '0');
           -- fincuenta <= '1'; --Cuando ha terminado de recorrer toda la imagen 2, activa el pinta_img
        elsif para_contador = '1' then --Cuando ha encontrado un pixel negro, para el contador para procesar el pixel
            cuenta <= cuenta + 0;
        elsif dout2 = '0' then
            cuenta <= cuenta - 1;
        else
            cuenta <= cuenta + 1;
            wea <= '1';
        end if;
    end if;
end process;

addr2_aux <= std_logic_vector (cuenta);

addr2 <= addr2_aux;
addr1 <= addr2_aux;
addr3 <= addr2_aux;

end Behavioral;