----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.03.2016 10:43:42
-- Design Name: 
-- Module Name: img_pkg - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.DCSE_PKG.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package IMG_PKG is

  constant dim_img  : natural := 65536; --Dimension de la imagen total
  constant lado_img : natural := 256; --Numero de pixel por lado de la imagen
  constant c_dim_img : natural := 16; --Numero de bits necesarios para las direcciones de la imagen
  constant c_lado_img : natural := 8; --Numero de bits necesarios para las direcciones de un lado de la imagen
  constant c_umbral : natural := 0; --Valor umbral para decidir si dos parches son parecidos o no
  constant c_bitscolor : natural := 8; --Numero de bits de profundidad de color de la imagen

end IMG_PKG;
