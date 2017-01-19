--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
-- Pinta barras para la Nexys2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.VGA_PKG.ALL; 
use WORK.DCSE_PKG.ALL;
use WORK.IMG_PKG.ALL;

entity PINTA_IMG is
  Port (
    -- In ports
    visible      : in std_logic;
    pxl_num      : in unsigned(c_nb_pxls-1 downto 0);
    line_num     : in unsigned(c_nb_lines-1 downto 0);
    datmem1      : in STD_LOGIC_VECTOR (7 downto 0);
    datmem3      : in STD_LOGIC_VECTOR (7 downto 0);
    
  --  datmen       : in std_logic;
    -- Out ports
    dirmem1      : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0); --18 -1?? c_2dim_img??
    dirmem3      : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
    red          : out std_logic_vector(c_nb_red-1 downto 0);
    green        : out std_logic_vector(c_nb_green-1 downto 0);
    blue         : out std_logic_vector(c_nb_blue-1 downto 0)
    

  );
end PINTA_IMG;

architecture behavioral of PINTA_IMG is

signal line_numx256 : unsigned (18 - 1 downto 0);
signal addr1, addr3 : unsigned (c_2dim_img - 1 downto 0);

begin

dirmem1 <= STD_LOGIC_VECTOR (addr1);
dirmem3 <= STD_LOGIC_VECTOR (addr3);

line_numx256 <= ('0'&(line_num(7 downto 0)-112)) * lado_img;
addr1 <= line_numx256 + (pxl_num(7 downto 0)-32);
addr3 <= line_numx256 + (pxl_num(7 downto 0)-352);

--addr1 <= line_numx256(15 downto 0) + (pxl_num(7 downto 0)-32);
--addr3 <= line_numx256(15 downto 0) + (pxl_num(7 downto 0)-352);

  P_pinta: Process (visible, pxl_num, line_num, datmem1)
  begin
    red   <= (others=>'0');
    green <= (others=>'0');
    blue  <= (others=>'0');
    if visible = '1' then
        if pxl_num > 32 and pxl_num < 288 and line_num > 112 and line_num < 368 then
                    red   <= datmem1 (7 downto 4);
                    green <= datmem1 (7 downto 4);
                    blue  <= datmem1 (7 downto 4);
        elsif pxl_num > 352 and pxl_num < 608 and line_num > 112 and line_num < 368 then
                    red   <= datmem3 (7 downto 4);
                    green <= datmem3 (7 downto 4);
                    blue  <= datmem3 (7 downto 4);
        else
                    red   <= "0010";
                    green <= "0111";
                    blue  <= "0011";
        end if;
  end if;
  end process;
  
  
end Behavioral;

