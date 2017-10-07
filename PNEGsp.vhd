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
           dout2 : in STD_LOGIC; --Valor del pxl de la R2
           fin_img : out STD_lOGIC; --Señal que indica que se ha terminado de recorrer la R2
           addr2 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de la cuenta de pixeles de la R2, que entra en R2
           addr1 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM1
           addr3 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM3
           para_contador : in STD_LOGIC); --Señal que viene de la máquina de estados e indica que se ha encontrado un pixel negro de la R2, parando así el contador de pixeles de la R2
end PNEGsp;

architecture Behavioral of PNEGsp is

 signal cuenta : unsigned (c_dim_img - 1 downto 0); --Cuenta para el contador de todos los píxeles de la R2
 constant c_fin_cuenta : natural := dim_img - 1; --Constante que indica el numero total de las imagenes

 signal addr2_aux : STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de la cuenta de pixeles de la R2
 signal addr1_ax : STD_LOGIC_VECTOR (c_dim_img - 1 downto 0);
 signal addr3_ax : STD_LOGIC_VECTOR (c_dim_img - 1 downto 0);
 
begin

addr1 <= addr1_ax;
addr3 <= addr3_ax;

--Contador de todos los píxeles de la imagen 2
P_CONT_IMG2: Process (rst, clk)
begin

    if rst = c_on then
        cuenta <= (others => '0');
        fin_img <= '0';
    elsif clk'event and clk = '1' then
        fin_img <= '0';
        if cuenta = c_fin_cuenta then --cuando termina de recorrer toda la imagen
            cuenta <= (others => '0');
            fin_img <= '1';
        elsif para_contador = '1' then --Cuando ha encontrado un pixel negro, para el contador para procesar el pixel
            cuenta <= cuenta + 0;
        elsif dout2 = '0' then --Se pierde un ciclo de reloj debido a la maquina de estados.
            cuenta <= cuenta - 1;
        else
            cuenta <= cuenta + 1;
        end if;
    end if;
end process;

addr2_aux <= std_logic_vector (cuenta); --Dirección de memoria de la cuenta de pixeles de la R2
addr2 <= addr2_aux;

p2: process (rst, clk)
begin
if rst = c_on then
    addr1_ax <= (others => '0');
    addr3_ax <= (others => '0');
elsif clk'event and clk = '1' then
    if dout2 = '0' then
    --puede ser addr2_aux -1 MIRAR!!
        addr1_ax <= addr2_aux; --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM1
        addr3_ax <= addr2_aux; --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM3
    else
        addr1_ax <= addr1_ax;
        addr3_ax <= addr3_ax;
    end if;
end if;
end process;


end Behavioral;