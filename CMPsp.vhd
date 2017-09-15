----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.VGA_PKG.ALL; 
use WORK.DCSE_PKG.ALL;
use WORK.IMG_PKG.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CMPsp is
Port ( compara_hecho : out STD_LOGIC; --Señal que indica que se han comparado los parches 3x3 (el parche de la ROM1 con el parche de la ROM3)
       busca_hecho_maqestados : in STD_LOGIC; --Señal que activa la comparación (resta) del pixel de la ROM1 con el pixel de la ROM3
       rst : in STD_LOGIC;
       dout2 : in STD_LOGIC; --Valor del pxl de la R2
       clk: in STD_LOGIC;
	   --led8 : out STD_LOGIC;
       wea1 : out STD_LOGIC; --Señal que indica la escritura en la RAM (imagen procesada)
       fin_compara : out STD_LOGIC; --Señal que indica se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
       fin_vecindad : in STD_LOGIC; --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
       asigna : in STD_LOGIC; --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos
       addr_esc : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria a escribir en la RAM
       dout1_3x3 : in STD_LOGIC; --Valor del pixel de la ROM1
       pxl_num_3x3 : in std_logic_vector (c_dim_img - 1 downto 0); --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
       pxl_dout3_3x3 : in STD_LOGIC --Valor del pixel del parche 3x3 de la ROM3
);
end CMPsp;

architecture Behavioral of CMPsp is

signal dout1_3x3_aux : STD_LOGIC; --Valor del pixel de la ROM1
signal pxl_dout3_3x3_aux : STD_LOGIC; --Valor del pixel del parche 3x3 de la ROM3
signal addr_esc_aux : STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria a escribir en la RAM

signal compara_hecho_aux : std_logic; --Señal auxiliar que indica que se ha procesado un parche completo (comparando el parche 3x3 de la ROM1 con el parche 3x3 de la ROM3)
signal comp_pxl : unsigned (1 downto 0); --Registro para guardar el valor del resultado de la resta de los dos parches 3x3 de la ROM1 y ROM3

signal cuenta : unsigned (4 downto 0); --Contador de los pixeles comparados dentro de un mismo parche 3x3 (ROM1 y ROM3)
signal dato_pxl_0, dato_pxl_1, dato_pxl_2, dato_pxl_3, dato_pxl_4, dato_pxl_5, dato_pxl_6, dato_pxl_7, dato_pxl_8 : unsigned (1 downto 0); --Valor de los pixeles comparados dentro de un mismo parche (resta del valor de ROM1 - ROM3) para su posterior suma
signal RESULTADO : unsigned (5 downto 0); --Resultado de la suma de los datos anteriores. Suma de los valores comparados de los 9 pixeles del parche 3x3 resultante de la comparación (resta)
signal suma : STD_lOGIC; --Señal que indica que se ha terminado la comparación de un parche 3x3 y se suman los valores de las nueve restas.

  --------SOLO PARA VER QUE OCURRE-------
--  signal led8_aux : STD_lOGIC;
  ---------------------------------------

begin

  --------SOLO PARA VER QUE OCURRE-------
--  led8 <= led8_aux;
  ---------------------------------------

dout1_3x3_aux <=  (dout1_3x3);
pxl_dout3_3x3_aux <=  (pxl_dout3_3x3);

--CONTADOR PARA LEER LOS 9 PIXELES PARA LAS 2 MEMORAS Y COMPARARLOS (RESTA)

P_RESTA: Process (rst,clk) 

begin
 
 if rst = c_on then        
    cuenta <= (others => '0');
    fin_compara <= '0';
    dato_pxl_0 <= (others => '0');
    dato_pxl_1 <= (others => '0');
    dato_pxl_2 <= (others => '0');
    dato_pxl_3 <= (others => '0');
    dato_pxl_4 <= (others => '0');
    dato_pxl_5 <= (others => '0');
    dato_pxl_6 <= (others => '0');
    dato_pxl_7 <= (others => '0');
    dato_pxl_8 <= (others => '0');
    
 elsif clk'event and clk = '1' then
 
---------------------------COMPARACIÓN (RESTA)-----------------------------------------------------------------------------------------------------------------
    if busca_hecho_maqestados = '1' then --Señal que activa la comparación (resta) del pixel de la ROM1 con el pixel de la ROM3
	   if (dout1_3x3_aux = '1' and pxl_dout3_3x3_aux = '1') or (dout1_3x3_aux = '0' and pxl_dout3_3x3_aux = '0') then
			comp_pxl <= "00";
		else
			comp_pxl <= "11";
		end if;
	else
		comp_pxl <= comp_pxl;
    end if;
---------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------Contador de los pixeles comparados dentro de un mismo parche 3x3 (ROM1 y ROM3)-----------------------------------------------------
    if asigna = '1' then --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos
        if cuenta = 0 then
            dato_pxl_0 <= comp_pxl; --Registro del pixel numero 1 del parche 3x3 resultante de la resta de los valores del primer pixel del parche 3x3 de la ROM1 y del primer pixel del parche 3x3 de la ROM3
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '1'; --Señal que indica se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
            suma <= '0'; --Señal que indica que se ha terminado de procesar (restar) los 9 pixeles de un parche 3x3 y se suman los valores guardados en los registros "dato_pxl_X"
        elsif cuenta = 1 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0'; 
		
		elsif cuenta = 2 then
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= comp_pxl;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
            cuenta <= cuenta + 1;
            fin_compara <= '1';
            suma <= '0';
		elsif cuenta = 3 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0'; 	
			
        elsif cuenta = 4 then
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= comp_pxl;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
            cuenta <= cuenta + 1;
            fin_compara <= '1';
            suma <= '0';
		elsif cuenta = 5 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0';	
			
        elsif cuenta = 6 then
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= comp_pxl;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
            cuenta <= cuenta + 1;
            fin_compara <= '1';
            suma <= '0';
		elsif cuenta = 7 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0';
			
        elsif cuenta = 8 then
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= comp_pxl;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;  
            cuenta <= cuenta + 1;
            fin_compara <= '1'; 
            suma <= '0'; 
		elsif cuenta = 9 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0';
			
        elsif cuenta = 10 then
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= comp_pxl;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
            cuenta <= cuenta + 1;
            fin_compara <= '1';
            suma <= '0';
		elsif cuenta = 11 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0';
			
        elsif cuenta = 12 then
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= comp_pxl;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
            cuenta <= cuenta + 1;
            fin_compara <= '1';
            suma <= '0';
		elsif cuenta = 13 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0';
			
        elsif cuenta = 14 then
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= comp_pxl;
			dato_pxl_8 <= dato_pxl_8;
            cuenta <= cuenta + 1;
            fin_compara <= '1';
            suma <= '0';
		elsif cuenta = 15 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0';
			
        elsif cuenta = 16 then 
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= comp_pxl;
            cuenta <= cuenta + 1;
            suma <= '1'; --Señal que indica que se ha terminado de procesar (restar) los 9 pixeles de un parche 3x3 y se suman los valores guardados en los registros "dato_pxl_X"
            fin_compara <= '0'; --'1'
		elsif cuenta = 17 then --Debido a los ciclos de reloj, se dan don pulsos de asigna, pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= cuenta + 1;
            fin_compara <= '0'; 
            suma <= '0';
		elsif cuenta = 18 then --Debido a los ciclos de reloj, se dan tres pulsos de asigna (hay que esperar a comprueba_hecho), pero solo nos intersa el primero de ellos, por eso los valores ahora se mantienen a cero menos los de los registros que se mantienen
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			cuenta <= (others => '0');
            fin_compara <= '0'; 
            suma <= '0';
			
        else
            dato_pxl_0 <= dato_pxl_0; 
            dato_pxl_1 <= dato_pxl_1;
			dato_pxl_2 <= dato_pxl_2;
			dato_pxl_3 <= dato_pxl_3;
			dato_pxl_4 <= dato_pxl_4;
			dato_pxl_5 <= dato_pxl_5;
			dato_pxl_6 <= dato_pxl_6;
			dato_pxl_7 <= dato_pxl_7;
			dato_pxl_8 <= dato_pxl_8;
			suma <= '0';
            cuenta <= (others => '0');  
            fin_compara <= '0';
        end if;
    end if;
 end if;
end process;      
---------------------------------------------------------------------------------------------------------------------------------------------------------------         
   
-----------------------------Proceso que suma los nueve resultados de las restas de los pixeles de los parches 3x3 de la ROM1 y la ROM3------------------------   
p2: process (rst, clk)
   begin

 if rst = '1' then
    RESULTADO <= (others => '0');
 elsif clk'event and clk = '1' then
   if suma = '1' then --Señal que indica que se ha terminado de procesar (restar) los 9 pixeles de un parche 3x3 y se suman los valores guardados en los registros "dato_pxl_X"
		RESULTADO <= ("0000"&dato_pxl_0) + ("0000"&dato_pxl_1) + ("0000"&dato_pxl_2) + ("0000"&dato_pxl_3) + ("0000"&dato_pxl_4) + ("0000"&dato_pxl_5) + ("0000"&dato_pxl_6) + ("0000"&dato_pxl_7) + ("0000"&dato_pxl_8); --Resultado de la suma de los datos anteriores. Suma de los valores comparados de los 9 pixeles del parche 3x3 resultante de la comparación (resta)
		compara_hecho <= '1'; --Señal que indica que se ha procesado un parche completo (comparando el parche 3x3 de la ROM1 con el parche 3x3 de la ROM3)
		compara_hecho_aux <= '1'; --Señal auxiliar que indica que se ha procesado un parche completo (comparando el parche 3x3 de la ROM1 con el parche 3x3 de la ROM3)
   else
		RESULTADO <= RESULTADO;
		compara_hecho <= '0';
		compara_hecho_aux <= '0';
   end if;
end if;
end process;
--------------------------------------------------------------------------------------------------------------------------------------------------------------- 

-------------------------------Proceso que compara el resultado con un valor umbral de "parecido" entre los parches de la ROM1 y la ROM3-----------------------
p3: process (resultado, compara_hecho_aux)
begin
if compara_hecho_aux = '1' then --Señal auxiliar que indica que se ha procesado un parche completo (comparando el parche 3x3 de la ROM1 con el parche 3x3 de la ROM3)
  --  if RESULTADO > c_umbral then --Se compara el resultado de la suma con un valor umbral definido en el paquete, para dar por bueno el parecido de los parches de la ROM1 y la ROM3 o no
    if RESULTADO = "000000000000" or RESULTADO > c_umbral then --Dado que ahora estoy analizando la imagen blanco y negro, y si los parches son exactamente el resultado será cero.
		wea1 <= '1'; --Señal que indica la escritura en la RAM (imagen procesada) 
--		wea1_aux <= '1';
    else 
        wea1 <= '0';
--		wea1_aux <= '0';
    end if;   
else
	wea1 <= '0';
--	wea1_aux <= '0';
end if;
end process; 
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------PROCESO DE PRUEBA----------------------------------------------------
--P_prueba: process (rst, clk)
-- if rst = '1' then
--    led8_aux <= '0'; 
-- elsif clk'event and clk = '1' then
--   if wea1_aux = '1' then 
--		led8_aux <= '1'; 
--   else
--		led8_aux <= led8_aux;
--   end if;
--end if;
--end process;

-------------------------Proceso que escoge la dirección del pixel a escribir en la RAM (imagen procesada)-----------------------------------------------------
p4: process (cuenta)
begin

if cuenta = 4 then  --El pixel que se está procesando, es decir, aquel que se querría pintar                     
    addr_esc_aux <= pxl_num_3x3; --Dirección del pixel a pintar de la ROM3 en la RAM
else
    addr_esc_aux <= addr_esc_aux;
end if;
end process;
---------------------------------------------------------------------------------------------------------------------------------------------------------------

addr_esc <= addr_esc_aux; --Dirección de memoria a escribir en la RAM

end Behavioral;