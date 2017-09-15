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

entity MAQsp is
    Port (  rst : in STD_LOGIC;
			clk : in STD_LOGIC;
			dout2 : in STD_LOGIC; --Valor del pxl de la R2
			fin_compara : in STD_LOGIC; --Señal que indica se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
			busca1_hecho : in STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM1
			busca_hecho : in STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM3
			para_vecindad_maqestados : in STD_LOGIC; --Señal que indica que se ha encontrado un pixel de la vecindad 11x11 de la ROM3
			compara_hecho : in STD_LOGIC; --Señal que indica que se han comparado los parches 3x3 (el parche de la ROM1 con el parche de la ROM3)
			fin_img : in STD_lOGIC; --Señal que indica que se ha terminado de recorrer la R2
			fin_vecindad : in STD_LOGIC; --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
           --fin_imagen : out STD_LOGIC; --Fin del procesado y que pinta la imagen procesada
			compara : out STD_LOGIC; --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
			para_vecindad : out STD_LOGIC; --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
			busca1_hecho_maqestados : out STD_LOGIC; --Señal que para el contador del parche 3x3 en cada pixel para su procesamiento
			espera_ciclo : out STD_LOGIC; --Señal que activa el contador del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
			asigna : out STD_LOGIC; --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos (modulo CMP)
			busca_hecho_maqestados : out STD_LOGIC; --Señal que activa la comparación (resta) del pixel de la ROM1 con el pixel de la ROM3
			para_contador : out STD_LOGIC;  --Señal que indica que se ha encontrado un pixel negro de la R2, parando así el contador de pixeles de la R2
			-----Señales LED para saber en que estado nos encontramos en cada momento-----------------------------------------
			led0 : out STD_LOGIC; --ESPERA
			led1 : out STD_LOGIC; --CICLORLJ
			led2 : out STD_LOGIC; --PARA
			led3 : out STD_LOGIC; --RESTA
			led4 : out STD_LOGIC; --COMPARA2
			led5 : out STD_LOGIC; --PINTA
			led6 : out STD_LOGIC; --COMPRUEBA
			led7 : out STD_LOGIC; --INIC
			led8 : out STD_LOGIC; --INIC
			led9 : out STD_LOGIC;
			led10 : out STD_LOGIC;
			led11 : out STD_LOGIC;
			led12 : out STD_LOGIC;
			led13 : out STD_LOGIC;
			led14 : out STD_LOGIC;
			led15 : out STD_LOGIC
		   );
end MAQsp;

architecture Behavioral of MAQsp is

  type estados is (Inic, pinta, Espera, CicloRLJ, Para, Resta, Compara2, Comprueba);
  signal estado_actual, estado_siguiente: estados;
  
  --------SOLO PARA VER QUE OCURRE-------
  signal led7_aux : STD_lOGIC;
  signal led8_aux : STD_lOGIC;
  signal cuenta_comprueba: unsigned (6 downto 0);
  ---------------------------------------

begin

  --------SOLO PARA VER QUE OCURRE-------
  led7 <= led7_aux;
  led8 <= led8_aux;
  led15 <= cuenta_comprueba (6);
  led14 <= cuenta_comprueba (5);
  led13 <= cuenta_comprueba (4);
  led12 <= cuenta_comprueba (3);
  led11 <= cuenta_comprueba (2);
  led10 <= cuenta_comprueba (1);
  led9 <= cuenta_comprueba (0);
  ---------------------------------------

P_COMB_ESTADO: Process (estado_actual, dout2, rst, busca1_hecho, para_vecindad_maqestados, busca_hecho, fin_compara, compara_hecho, fin_vecindad, fin_img, cuenta_comprueba, led7_aux, led8_aux)
    begin
    
        case estado_actual is 
            when Inic =>
                if dout2 = '0' then
                    estado_siguiente <= espera;  --ESPERA: Cuando se ha encontrado un pixel negro en la R2 (dout2='0'), se para el contador de pixeles de la R2 y se activa el parche 3x3 de la ROM1        
                else 
                    estado_siguiente <= Inic;  
                end if;
             when pinta =>
                if rst = '1' then
                    estado_siguiente <= Inic;
                else
                    estado_siguiente <= pinta;
                end if;
             when espera =>
                if busca1_hecho = '1' and para_vecindad_maqestados = '1' then --Cuando se ha encontrado un pixel del parche 3x3 de la ROM1 (busca1_hecho) y un pixel de la vecindad 11x11 de la ROM3 (para_vecindad_maqestados)
                    estado_siguiente <= CicloRLJ; --CICLORLJ: Se para (además del contador parado en espera) el contador de la vecindad 11x11 de la ROM3, empezando así el parche 3x3 de la ROM3; y también se para el contador del parche 3x3 de la ROM1
                else
                    estado_siguiente <= espera;
                end if;
            when CicloRLJ =>
                if busca1_hecho = '1' then 
                   estado_siguiente <= Para; --PARA: Se activa (dejando parados los contadores en cicloRLJ) el contador del parche 3x3 de la ROM3
                else
                   estado_siguiente <= Para;
                end if;
            when Para =>
                if busca_hecho = '1' then --Cuando se ha encotnrado un pixel del parche 3x3 de la ROM3
                    estado_siguiente <= Resta; --RESTA: Se desactiva el contador del parche 3x3 de la ROM3 (dejando parados los contadores de cicloRLJ), además se activa la comparación (resta) de los pixeles de los parches 3x3 de la ROM1 y ROM3
                else
                    estado_siguiente <= Para; 
                end if;
            when Resta =>
                if fin_compara = '1' then 
                    estado_siguiente <= Compara2;
                else
                    estado_siguiente <= Compara2;
                end if;
            when Compara2 =>
                if fin_img = '1' then --Cuando se ha terminado de recorrer la R2, es decir, se ha terminado de procesar la imagen
                    estado_siguiente <= Pinta; --PINTA: Se paran todos los contadores y se termina el procesado, pintando así la imagen procesada
--				elsif fin_vecindad = '1' and compara_hecho = '1' then --Cuando se ha terminado la vecindad 11x11 de un pixel de la ROM3
--                    estado_siguiente <= Inic; --INIC: Se vuelven a activar todos los contadores comenzando así un nuevo procesamiento de un nuevo pixel
				elsif compara_hecho = '1' then --Cuando se ha terminado de comparar un parche de 3x3 completo (el de la ROM1 con el de la ROM3)
                    estado_siguiente <= Espera; --Se vuelve a ESPERA, para comenzar a comparar los dos siguientes pixeles (ROM1 y ROM3) del siguiente parche
				elsif fin_compara = '1' then  --Cuando se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
                    estado_siguiente <= Comprueba; --COMPRUEBA: Se mantinen parados el contador de pixeles de la R2, se activa el contador de pixeles dentro de un mismo parche de la ROM1, y el contador de pixeles de un parche 3x3 de la ROM3
				else
					estado_siguiente <= Compara2; --COMPARA2: Se mantienen los contadores del estado resta, se desactiva la comparación entre los pixeles (resta) y se activa la suma de +1 en los contadores de pixeles de los parches 3x3 de ROM1 y ROM3 asegurando que se han comparando entre ellos (en el modulo CMP)
				end if;
            when Comprueba =>
                if busca1_hecho = '1' and busca_hecho = '1' then --Cuando se han encontrado los dos nuevos pixeles dentro de un mismo parche tanto de la ROM1 como de la ROM3
                     estado_siguiente <= Resta; --RESTA: Se desactiva el contador del parche 3x3 de la ROM3 (dejando parados los contadores de cicloRLJ), además se activa la comparación (resta) de los pixeles de los parches 3x3 de la ROM1 y ROM3
                else
                     estado_siguiente <= Comprueba;
                end if;
        end case;
		
--------------SOLO PARA VER QUE OCURRE-------
	if rst = '1' then
		led7_aux <= '0';
		led8_aux <= '0';
		cuenta_comprueba <= (others => '0');
	else
		if compara_hecho = '1' then
			if fin_vecindad = '1' and compara_hecho = '1' then
				led7_aux <= '1';
				cuenta_comprueba <= cuenta_comprueba + 1;
				led8_aux <= led8_aux;
			elsif fin_vecindad = '1'  then
				led8_aux <= '1';
				led7_aux <= led7_aux;
				cuenta_comprueba <= cuenta_comprueba + 0;
			elsif cuenta_comprueba = "1111111" then
                led7_aux <= led7_aux;
                cuenta_comprueba <= cuenta_comprueba + 0;
                led8_aux <= led8_aux;
			else
				cuenta_comprueba <= cuenta_comprueba + 1;
				led7_aux <= led7_aux;
			end if;
		else
			led7_aux <= led7_aux;
			cuenta_comprueba <= cuenta_comprueba + 0;
			led8_aux <= led8_aux;
		end if;
	end if;
--------------------------------------------
		
    end process;                      

P_SEQ_FSM: Process (Clk, Rst)
begin
        if rst = '1' then
            estado_actual <= Inic; 
        elsif Clk'event and Clk = '1' then
            estado_actual <= estado_siguiente;
        end if;
end process;
    
P_COM_SALIDAS: Process (estado_actual)
 begin
       
           case estado_actual is
               when Inic =>
                   para_contador <= '0'; --Señal que para el contador de pixeles de la R2
                   compara <= '0'; --Señal que activa el contador del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
                   para_vecindad <= '0'; --Señal que para el contador de la vecindad 11x11 de la ROM3 para comenzar con el contador del parche 3x3 de la ROM3
                   busca1_hecho_maqestados <= '0'; --Señal que para el contador del parche 3x3 de la ROM1
                   busca_hecho_maqestados <= '0'; --Señal que activa la comparación (resta) de los pixeles de los parches de la ROM1 de la ROM3
                   espera_ciclo <= '0'; --Señal que activa el contador del parche 3x3 dentro de la vecindad 11x11 de la ROM3
                   asigna <= '0'; --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos (modulo CMP)
--                   fin_imagen <= '0'; --Fin del procesado y que pinta la imagen procesada
				   
				   led0 <= '0';
				   led1 <= '0';
				   led2 <= '0';
				   led3 <= '0';
				   led4 <= '0';
				   led5 <= '0';
				   led6 <= '0';	
				--   led7	<= '1';			   
               when Pinta => --PINTA: Se paran todos los contadores y se termina el procesado, pintando así la imagen procesada
                   para_contador <= '1'; 
                   compara <= '0';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '0';
                   espera_ciclo <= '0';
                   asigna <= '0';
--                   fin_imagen <= '1';
				   
				   led0 <= '0';
				   led1 <= '0';
				   led2 <= '0';
				   led3 <= '0';
				   led4 <= '0';
				   led5 <= '1';
				   led6 <= '0';	
				--   led7	<= '0';
               when espera => --ESPERA: Cuando se ha encontrado un pixel negro en la R2 (dout2='0'), se para el contador de pixeles de la R2 y se activa el parche 3x3 de la ROM1   
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '0';
                   busca1_hecho_maqestados <= '0';
                   busca_hecho_maqestados <= '0';
                   espera_ciclo <= '0';
                   asigna <= '0';
--                   fin_imagen <= '0';
				   
				   led0 <= '1';
				   led1 <= '0';
				   led2 <= '0';
				   led3 <= '0';
				   led4 <= '0';
				   led5 <= '0';
				   led6 <= '0';	
				  -- led7	<= '0';
               when CicloRLJ => --CICLORLJ: Se para (además del contador parado en espera) el contador de la vecindad 11x11 de la ROM3, empezando así el parche 3x3 de la ROM3; y también se para el contador del parche 3x3 de la ROM1
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '0'; 
                   espera_ciclo <= '0';
                   asigna <= '0';
--                   fin_imagen <= '0';
				   
				   led0 <= '0';
				   led1 <= '1';
				   led2 <= '0';
				   led3 <= '0';
				   led4 <= '0';
				   led5 <= '0';
				   led6 <= '0';	
				 --  led7	<= '0';
               when para => --PARA: Se activa (dejando parados los contadores en cicloRLJ) el contador del parche 3x3 de la ROM3
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '0'; 
                   espera_ciclo <= '1';
                   asigna <= '0';
--                   fin_imagen <= '0';
				   
				   led0 <= '0';
				   led1 <= '0';
				   led2 <= '1';
				   led3 <= '0';
				   led4 <= '0';
				   led5 <= '0';
				   led6 <= '0';	
				--   led7	<= '0';
               when Resta => --RESTA: Se desactiva el contador del parche 3x3 de la ROM3 (dejando parados los contadores de cicloRLJ), además se activa la comparación (resta) de los pixeles de los parches 3x3 de la ROM1 y ROM3
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '1'; 
                   espera_ciclo <= '0';
                   asigna <= '0';
--                   fin_imagen <= '0';
				   
				   led0 <= '0';
				   led1 <= '0';
				   led2 <= '0';
				   led3 <= '1';
				   led4 <= '0';
				   led5 <= '0';
				   led6 <= '0';	
				--   led7	<= '0';
               when compara2 => --COMPARA2: Se mantienen los contadores del estado resta, se desactiva la comparación entre los pixeles (resta) y se activa la suma de +1 en los contadores de pixeles de los parches 3x3 de ROM1 y ROM3 asegurando que se han comparando entre ellos (en el modulo CMP)
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '0';
                   espera_ciclo <= '0';
                   asigna <= '1';
--                   fin_imagen <= '0';
				   
				   led0 <= '0';
				   led1 <= '0';
				   led2 <= '0';
				   led3 <= '0';
				   led4 <= '1';
				   led5 <= '0';
				   led6 <= '0';	
				--   led7	<= '0';
               when comprueba => --COMPRUEBA: Se mantinen parados el contador de pixeles de la R2, se activa el contador de pixeles dentro de un mismo parche de la ROM1, y el contador de pixeles de un parche 3x3 de la ROM3
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '0';
                   busca_hecho_maqestados <= '0';
                   espera_ciclo <= '1';
                   asigna <= '0';
--                   fin_imagen <= '0';
				   
				   led0 <= '0';
				   led1 <= '0';
				   led2 <= '0';
				   led3 <= '0';
				   led4 <= '0';
				   led5 <= '0';
				   led6 <= '1';	
				--   led7	<= '0';
           end case;
  end process;   

end Behavioral;