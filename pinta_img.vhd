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
    visible      : in std_logic;
    pxl_num      : in std_logic_vector(c_nb_pxls-1 downto 0);
    line_num     : in std_logic_vector(c_nb_lines-1 downto 0);
    datmem1      : in STD_LOGIC; --Valor de los pixeles de la imagen procesada (RAM)
    datmem3      : in STD_LOGIC; --Valor de los pixeles de la ROM3 sin procesar
--    fin_imagen : in STD_LOGIC; --Fin del procesado y que pinta la imagen procesada
   -- SW : in STD_LOGIC;
    dirmem1      : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de los pixeles de la imagen procesada (RAM)
    dirmem3      : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de los pixeles de la ROM3 sin procesar
    red          : out std_logic_vector(c_nb_red-1 downto 0);
    green        : out std_logic_vector(c_nb_green-1 downto 0);
    blue         : out std_logic_vector(c_nb_blue-1 downto 0)
  );
end PINTA_IMG;

architecture behavioral of PINTA_IMG is

signal line_numx256 : unsigned (18 - 1 downto 0);
signal addr3 : unsigned (c_dim_img - 1 downto 0); --Dirección de memoria de los pixeles de la ROM3 sin procesar
signal addr1 : unsigned (c_dim_img - 1 downto 0); --Dirección de memoria de los pixeles de la imagen procesada (RAM)
signal pixel_num : unsigned (c_nb_pxls-1 downto 0);
signal lin_num : unsigned (c_nb_lines-1 downto 0);

begin

pixel_num <= unsigned (pxl_num);
lin_num <= unsigned (line_num);
dirmem1 <= STD_LOGIC_VECTOR (addr1); --Dirección de memoria de los pixeles de la imagen procesada (RAM)
dirmem3 <= STD_LOGIC_VECTOR (addr3); --Dirección de memoria de los pixeles de la ROM3 sin procesar

---------Calculo de las direcciones de memoria correspondientes a las lineas para pintar las imagenes en la VGA---------
line_numx256 <= ('0'&(lin_num(7 downto 0)-112)) * lado_img; --Se resta 112 lineas, porque se empieza a pintar en la linea 112 para centrar las imagenes en el medio de la VGA

---------Calculo de la dirección de memoria correspondientes a las columnas de la RAM para pintar la imagen en la VGA---
addr1 <= line_numx256(15 downto 0) + (pixel_num(7 downto 0)-32); --Se resta 32 columnas, porque se empieza a pintar en la columna 32 para centrar esta imagen en el medio de la mitad izquierda

---------Calculo de la dirección de memoria correspondientes a las columnas de la ROM3 para pintar la imagen en la VGA---
addr3 <= line_numx256(15 downto 0) + (pixel_num(7 downto 0)-352); --Se resta 352 columnas, porque se empieza a pintar en la columna 352 para centrar esta imagen en el medio de la mitad derecha

  P_pinta: Process (visible, pixel_num, lin_num, datmem1, datmem3)
  begin
    red   <= (others=>'0');
    green <= (others=>'0');
    blue  <= (others=>'0');
   -- if fin_imagen = '1' then
        if visible = '1' then
           -- if SW = '1' then
                if pixel_num > 32 and pixel_num < 288 and lin_num > 112 and lin_num < 368 then
                            red   <= (others => datmem1);
                            green <= (others => datmem1);
                            blue  <= (others => datmem1);
                elsif pixel_num > 352 and pixel_num < 608 and lin_num > 112 and lin_num < 368 then
                            red   <= (others => datmem3);
                            green <= (others => datmem3);
                            blue  <= (others => datmem3);
                else
                            red   <= "0010";
                            green <= "0111";
                            blue  <= "0011";
                end if;
         --  else
         --       if pxl_num > 352 and pxl_num < 608 and line_num > 112 and line_num < 368 then
         --                      red   <= datmem3 (7 downto 4);
         --                      green <= datmem3 (7 downto 4);
         --                      blue  <= datmem3 (7 downto 4);
         --       else
         --                      red     <= (others => '0');
         --                      green <= (others => '0');
         --                      blue     <= (others => '1');
         --       end if;
         --  end if;
       end if;
 -- end if;
  end process;
  
  
end Behavioral;

