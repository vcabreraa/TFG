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

  constant dim_img  : natural := 256 * 256;
  constant lado_img : natural := 256;
  constant c_dim_img : natural := log2i(dim_img) + 1;
  constant c_lado_img : natural := log2i(lado_img) + 1;
  constant c_2dim_img : natural := 18; --c_dim_img*2
  constant c_umbral : natural := 100;

end IMG_PKG;
