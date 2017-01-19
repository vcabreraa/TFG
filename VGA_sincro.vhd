----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.06.2016 11:44:35
-- Design Name: 
-- Module Name: VGA_sincro - Behavioral
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
-----------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.VGA_PKG.ALL; 
use WORK.DCSE_PKG.ALL;

entity VGA_sincro is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           hsynch : out STD_LOGIC;
           vsynch : out STD_LOGIC;
           visible : out STD_LOGIC;
           line_num : out STD_LOGIC_VECTOR (c_nb_lines-1 downto 0); -- 9 downto 0
           pxl_num : out STD_LOGIC_VECTOR (c_nb_pxls-1 downto 0));  -- 9 downto 0
end VGA_sincro;

-------------------------------------------------------------------------------------------------------------------------------------------------

architecture Behavioral of VGA_sincro is

-- Divisor de frecuencia
signal cont_clk : unsigned (c_nb_cont_clk-1 downto 0);
signal new_pxl: STD_LOGIC;

-- Contador de pixeles
signal visible_pxl : STD_LOGIC;
signal new_line : STD_LOGIC;
signal cont_pxl : unsigned (c_nb_pxls-1 downto 0);
constant fin_cont_pxl: natural := 799;

-- Contador de lineas
signal visible_line : STD_LOGIC;
signal cont_line : unsigned (c_nb_lines-1 downto 0);
constant fin_cont_line: natural := 519;

-------------------------------------------------------------------------------------------------------------------------------------------------

begin

-- Divisor de frecuencia de 100Mhz a 25Mhz
P_cont_clk: Process(rst,clk)

    begin
    if rst = c_on then
        cont_clk <= (others => '0');
    elsif clk'event and clk = '1' then
        if cont_clk = c_fin_cuenta_clk - 1 then 
            cont_clk <= (others => '0');
        else
            cont_clk <= cont_clk + 1;           
        end if;
    end if;
    end Process;
    
-- Proceso combinacional del divisor de frecuencia
P_pxl_clk: Process(cont_clk)

    begin
    if cont_clk = c_fin_cuenta_clk - 1 then
        new_pxl <= '1';
    else
        new_pxl <= '0';
    end if;
    end Process;

-------------------------------------------------------------------------------------------------------------------------------------------------
    
-- Contador de los pixeles de cada linea (sincronismo horizontal)
P_cont_pxl: Process(rst,clk)

    begin
    if rst = c_on then
        cont_pxl <= (others => '0');
    elsif clk'event and clk = '1' then
        if new_pxl = '1' then  -- Cada vez que se envia un nuevo pixel:
            if cont_pxl = fin_cont_pxl then  -- Cuando la cuenta llega a fin de cuenta (799 pixeles) vuelve a cero
                cont_pxl <= (others => '0');
            else
                cont_pxl <= cont_pxl + 1;
            end if;
        end if;
    end if;
    end Process;
    
pxl_num <= STD_LOGIC_VECTOR (cont_pxl);  -- El valor del pixel por el que va contando coincide con cont_pxl

-- Proceso combinacional del contador de pixeles
P_comb_cont_pxl: Process (cont_pxl)

    begin   
    if cont_pxl > c_pxl_2_fporch-1 and cont_pxl < c_pxl_2_synch then  -- valores de pixel entre 655 y 752
        hsynch <= '0'; -- Hay sincronismo horizonal, por lo que se pone un cero
        new_line <= '0';
        visible_pxl <= '0';
    elsif cont_pxl >= 0 and cont_pxl < c_pxl_visible  then  -- valores entre 0 y 640
        visible_pxl <= '1';
        hsynch <= '1';
        new_line <= '0';
    elsif cont_pxl = fin_cont_pxl then  -- Cuando los pixeles llegan al fin de cuenta (cont_pxl = 799)
        new_line <= '1';  -- Se empieza una nueva linea
        hsynch <= '1';
        visible_pxl <= '0';
    else
        new_line <= '0';
        visible_pxl <= '0';
        hsynch <= '1'; --  no hay sincronismo, se pone un uno
    end if;
    end Process;
    
-------------------------------------------------------------------------------------------------------------------------------------------------
    
-- Contador de lineas (filas)
P_cont_line: Process (rst, clk)

    begin
    if rst = c_on then
        cont_line <= (others => '0');
    elsif clk'event and clk = '1' then
        if new_line = '1' and new_pxl = '1' then  --Cuando se empieza una nueva línea y se envia un nuevo pixel
            if cont_line = fin_cont_line then
                cont_line <= (others => '0');
            else
                cont_line <= cont_line + 1;
            end if;
        end if;
    end if;
    end Process;

line_num <= STD_LOGIC_VECTOR (cont_line); -- Indica la linea en la que se encuentra

P_comb_cont_line: Process (cont_line)

    begin
    if cont_line > c_line_2_fporch and cont_line < c_line_2_synch then -- valores de cont_line entre 489 y 491
        vsynch <= '0'; -- Cuando hay sincronismo vertical se pone un cero
        visible_line <= '0';
    elsif cont_line >= c_line_visible then -- valores mayores de 480  (visible de 0 a 479) Valores entre 480 y 489 y entre 491 y 520 no visible
        visible_line <= '0';
        vsynch <= '1';
    else --  valores de c_line_visible entre 0 y 480
        vsynch <= '1';  -- Cuando no hay sincronismo se pone un uno
        visible_line <= '1';
    end if;
    end Process;
    
visible <= '1' when (visible_pxl = '1' and visible_line = '1') else '0';
                
end Behavioral;
