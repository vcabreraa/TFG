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

entity BUSCAsp is
    Port ( 
           fin_vecindad : out STD_LOGIC; --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
           espera_ciclo : in STD_LOGIC; --Señal que activa el contador del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
           busca_hecho : out STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM3
           busca1_hecho_maqestados : in STD_LOGIC; --Señal que para el contador del parche 3x3 en cada pixel para su procesamiento
           busca1_hecho : out STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM1
           para_vecindad: in STD_LOGIC; --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
           para_vecindad_maqestados: out STD_LOGIC; --Señal que indica que se ha encontrado un pixel de la vecindad 11x11 de la ROM3
           addr3 : in STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria que indica el pixel de la R2 y va a la ROM3
           addr1 : in STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria que indica el pixel de la R2 y va a la ROM1
           addr1_3x3 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Direción de memoria del pixel del parche 3x3 de la ROM1
           pxl_num_3x3 : out STD_LOGIC_VECTOR (c_dim_img-1 downto 0); --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
           clk: in STD_LOGIC;
           rst: in STD_LOGIC;
--           asigna : in STD_LOGIC; --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos (modulo CMP)
           compara : in STD_LOGIC); --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
           
end BUSCAsp;

architecture Behavioral of BUSCAsp is

signal cuenta_seguridad : STD_LOGIC; --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados en la cuenta del parche 3x3 de la ROM1
signal cuenta_seguridad_11x11 : STD_LOGIC; --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados en la cuenta de la vecindad 11x11 de la ROM3
signal cuenta_seguridad_3x3 : STD_LOGIC; --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados en la cuenta del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
signal cuenta_seguridad_line : STD_LOGIC;
signal cuenta_seguridad_line_11x11 : STD_LOGIC;
signal cuenta_seguridad_line_3x3 : STD_LOGIC;


signal addr1_aux: unsigned (c_dim_img - 1 downto 0);
signal addr3_aux: unsigned (c_dim_img - 1 downto 0);

--------SEÑALES AUXILIARES----------
signal busca1_hecho_aux : STD_LOGIC; 
signal busca_hecho_aux : STD_LOGIC;
signal para_vecindad_maqestados_aux : STD_LOGIC;

--parche 3x3 ROM1----------------------------------------------------------------------------------------------------------------
signal cont_pxl_3x3_1 : unsigned (c_dim_img - 1 downto 0); -- Contador de pixeles dentro de una linea del parche 3x3 de la ROM1

signal new_line_3x3_1 : std_Logic; --Señal de nueva linea dentro del parche 3x3 de la ROM1
signal cont_line_3x3_1 : unsigned (1 downto 0); --Contador de lineas del parche 3x3 de la ROM1

signal addr1_3x3_aux : unsigned (c_dim_img - 1 downto 0); --Dirección de memoria del pixel del parche 3x3 de la ROM1
---------------------------------------------------------------------------------------------------------------------------------

--Vecindad 11x11 ROM3-------------------------------------------------------------------------------------------------------------------
signal cont_pxl_11x11 : unsigned (c_dim_img - 1 downto 0); -- Contador de pixeles dentro de una linea de la vecindad 11x11 de la ROM3

signal cont_line_11x11 : unsigned (4 downto 0); --Contador de lineas de la vecindad 11x11 de la ROM3
signal new_line_11x11 : STD_LOGIC; --Señal de nueva linea dentro de la vecindad 11x11 de la ROM3
constant fin_cont_line_11x11: natural := 10; --Constante que indica el numero de lineas de la vecindad 11xx11 de la ROM3

signal pxl_num_11x11 : unsigned (c_dim_img - 1 downto 0); --Dirección de memoria del pixel de la vecindad 11x11 de la ROM3
----------------------------------------------------------------------------------------------------------------------------------------

--Parche 3x3 dentro de la vecindad 11x11 ROM3----------------------------------------------------------------------------------------------------------------
signal cont_pxl_3x3 : unsigned (c_dim_img - 1 downto 0); -- Contador de pixeles dentro de una linea del parche 3x3 dentro de la vecindad 11x11 de la ROM3

signal new_line_3x3 : STD_LOGIC; --Señal de nueva linea del parche 3x3 dentro de la vecindad 11x11 de la ROM3
signal cont_line_3x3 : unsigned (1 downto 0); --Contador de lineas del parche 3x3 dentro de la vecindad 11x11 de la ROM3
constant fin_cont_line_3x3: natural := 2; --Constante que indica el numero de lineas del parche 3x3 dentro de la vecindad 11x11 de la ROM3
signal line_num_3x3 : std_Logic_vector (1 downto 0); -- Indica la linea en la que se encuentra el parche 3x3 dentro de la vecindad de la ROM3

signal pxl_num_3x3_aux : unsigned (c_dim_img-1 downto 0); --Dirección de memoria del pixel del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
-------------------------------------------------------------------------------------------------------------------------------------------------------------

begin

addr1_aux <= unsigned (addr1);
addr3_aux <= unsigned (addr3);

addr1_3x3 <= STD_lOGIC_VECTOR (addr1_3x3_aux); --Dirección de memoria del pixel del parche 3x3 de la ROM1
pxl_num_3x3 <= STD_lOGIC_VECTOR (pxl_num_3x3_aux); --Dirección de memoria del pixel del parche 3x3 del pixel de la vecindad 11x11 de la ROM3


----------------- Parche 3x3 de la ROM1 -------------
-- Contador de los píxeles de cada línea 
P_cont_pxl_3x3_1: Process(rst,clk)

    begin
    if rst = c_on then
        cont_pxl_3x3_1 <= (others => '0'); 
    elsif clk'event and clk = '1' then	
        cont_pxl_3x3_1 <= addr1_aux - (lado_img + 1);
		if busca1_hecho_aux = '1' then --Cada pixel del parche 3x3, para indicar que se realiza el procesamiento de ese pixel
			if cuenta_seguridad = '0' then --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados
				if cont_pxl_3x3_1 = addr1_aux - (lado_img + 1) + 2 then  -- Cuando llega al fin de cuenta (Se han contado 3 pixeles)
					cont_pxl_3x3_1 <= addr1_aux - (lado_img + 1);
					cuenta_seguridad <= '1';
				else
					cont_pxl_3x3_1 <= cont_pxl_3x3_1 + 1;
					cuenta_seguridad <= '1';
				end if;
			else
				cont_pxl_3x3_1 <= cont_pxl_3x3_1 + 0;
				cuenta_seguridad <= cuenta_seguridad;
			end if;
        else
            cont_pxl_3x3_1 <= cont_pxl_3x3_1 + 0;
			cuenta_seguridad <= '0';
        end if;
	end if;
	end Process;
    
P_comb_cont_pxl_3x3_1: Process (compara, busca1_hecho_maqestados, cont_pxl_3x3_1, addr1_aux)
begin
if compara = '1' then --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
      if busca1_hecho_maqestados = '0' then --Señal que para el contador del parche 3x3 en cada pixel para su procesamiento(cuando busca1_hecho_maqestados = '1')
             if cont_pxl_3x3_1 = addr1_aux - (lado_img + 1) + 2 then --Se han contado 3 pixeles
                    busca1_hecho <= '1'; --Cada pixel del parche 3x3, para indicar que se realiza el procesamiento de ese pixel
                    busca1_hecho_aux <= '1'; --Cada pixel del parche 3x3, para indicar que se realiza el procesamiento de ese pixel
                    new_line_3x3_1 <= '1'; --Se ha completado una linea de 3 pixeles (parche de 3x3)
             else
                    busca1_hecho <= '1'; --Cada pixel del parche 3x3, para indicar que se realiza el procesamiento de ese pixel
                    busca1_hecho_aux <= '1';
                    new_line_3x3_1 <= '0';
             end if;
      else 
          busca1_hecho <= '0';
          busca1_hecho_aux <= '0';
          new_line_3x3_1 <= '0';
      end if;
else
	busca1_hecho <= '0';
    busca1_hecho_aux <= '0';
    new_line_3x3_1 <= '0';
end if;
end Process;

    
-- Contador de lineas (filas)
P_cont_line_3x3_1: Process (rst, clk)
        
    begin
    if rst = c_on then
        cont_line_3x3_1 <= (others => '0');
    elsif clk'event and clk = '1' then
        if new_line_3x3_1 = '1' then  --Cuando se empieza una nueva línea y se envia un nuevo pixel
            if cuenta_seguridad_line = '0' then --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados
				if cont_line_3x3_1 = fin_cont_line_3x3 then --Cuando se han contado 3 lineas
					cont_line_3x3_1 <= (others => '0');
					cuenta_seguridad_line <= '1';
				else
					cont_line_3x3_1 <= cont_line_3x3_1 + 1;
					cuenta_seguridad_line <= '1';
				end if;
			else	
				cuenta_seguridad_line <= cuenta_seguridad_line;
				cont_line_3x3_1 <= cont_line_3x3_1 + 0;
			end if;
		else
			cont_line_3x3_1 <= cont_line_3x3_1;
			cuenta_seguridad_line <= '0';
        end if;
    end if;
    end Process;    
    
addr1_3x3_aux <= cont_pxl_3x3_1 + ("00000"&cont_line_3x3_1) * lado_img; --Dirección de memoria del pixel del parche 3x3 de la ROM1


--  ---------------vecindad 11x11 de la ROM3----------------   
-- Contador de los pixeles de cada linea 
P_cont_pxl_11x11: Process(rst,clk)
  
    begin
    if rst = c_on then
        cont_pxl_11x11 <= (others => '0');
    elsif clk'event and clk = '1' then
        cont_pxl_11x11 <= addr3_aux - (lado_img * 5) - 5;
		if para_vecindad_maqestados_aux = '1' then --Cada pixel de la vecindad 11x11, para indicar que se va a realiza el parche 3x3 de ese pixel
			if cuenta_seguridad_11x11 = '0' then --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados
				if cont_pxl_11x11 = (addr3_aux - lado_img * 5 - 5) + 10 then  -- Cuando llega al fin de cuenta de los pixeles de una linea de 11
					cont_pxl_11x11 <= addr3_aux - (lado_img * 5) -5; 
					cuenta_seguridad_11x11 <= '1';
				else
					cont_pxl_11x11 <= cont_pxl_11x11 + 1;
					cuenta_seguridad_11x11 <= '1';
				end if;
			else
				cont_pxl_11x11 <= cont_pxl_11x11 + 0;
				cuenta_seguridad_11x11 <= cuenta_seguridad_11x11;
			end if;
		else
			cont_pxl_11x11 <= cont_pxl_11x11 + 0;
			cuenta_seguridad_11x11 <= '0';
		end if;
	end if;
    end Process;
   
p_comb: Process (compara, para_vecindad, cont_pxl_11x11, addr3_aux)
begin
	if compara = '1' then --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
		if para_vecindad = '0' then --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3 (cuando para_vecindad = '1')
            if cont_pxl_11x11 = (addr3_aux - lado_img * 5 - 5) + 10 then  -- Cuando llega al fin de cuenta de los pixeles de una linea de 11
                new_line_11x11 <= '1'; --Se ha completado una linea de 11 pixeles (vecindad de 11x11)
                para_vecindad_maqestados <= '1'; --Cada pixel de la vecindad 11x11, para indicar que se va a realiza el parche 3x3 de ese pixel
                para_vecindad_maqestados_aux <= '1'; --Cada pixel de la vecindad 11x11, para indicar que se va a realiza el parche 3x3 de ese pixel
            else
                new_line_11x11 <= '0';
                para_vecindad_maqestados <= '1'; --Cada pixel que encuentra va a parar, para hacer su parche 3x3
                para_vecindad_maqestados_aux <= '1';
            end if;
        else
            new_line_11x11 <= '0';
            para_vecindad_maqestados <= '0';
            para_vecindad_maqestados_aux <= '0';
        end if;
	else
		new_line_11x11 <= '0';
        para_vecindad_maqestados <= '0';
        para_vecindad_maqestados_aux <= '0';
    end if;
end Process;

  -- Contador de lineas (filas)
P_cont_line_11x11: Process (rst, clk)
      
begin
    if rst = c_on then
        cont_line_11x11 <= (others => '0');
    elsif clk'event and clk = '1' then
        if new_line_11x11 = '1' then  --Cuando se empieza una nueva línea y se envia un nuevo pixel
            if cuenta_seguridad_line_11x11 = '0' then --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados    
				if cont_line_11x11 = fin_cont_line_11x11 then --Cuando se han contado 11 lineas
                    cont_line_11x11 <= (others => '0');
					cuenta_seguridad_line_11x11 <= '1';
                else
                    cont_line_11x11 <= cont_line_11x11 + 1;
					cuenta_seguridad_line_11x11 <= '1';
                end if;
			else
				cont_line_11x11 <= cont_line_11x11 + 0;
				cuenta_seguridad_line_11x11 <= cuenta_seguridad_line_11x11;
			end if;
		else
			cont_line_11x11 <= cont_line_11x11;
			cuenta_seguridad_line_11x11 <= '0';
        end if;
	end if;
end Process;    

pxl_num_11x11 <= cont_pxl_11x11 + (("00"&cont_line_11x11) * lado_img); --Dirección de memoria del pixel de la vecindad 11x11 de la ROM3


-------------Parche de 3x3 de cada pixel de la vecindad 11x11 ROM3-------
--Proceso que cuenta los pixeles
P_cont_pxl_3x3: Process(rst,clk)

    begin
    if rst = c_on then
        cont_pxl_3x3 <= (others => '0'); 
    elsif clk'event and clk = '1' then
        cont_pxl_3x3 <= pxl_num_11x11 - (lado_img + 1);
		if busca_hecho_aux = '1' then --Cada pixel del parche 3x3, para indicar que se realiza el procesamiento de ese pixel
			if cuenta_seguridad_3x3 = '0' then --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados
				if cont_pxl_3x3 = pxl_num_11x11 - (lado_img + 1) + 2 then
                    cont_pxl_3x3 <= pxl_num_11x11 - (lado_img + 1);
					cuenta_seguridad_3x3 <= '1';
				else
					cont_pxl_3x3 <= cont_pxl_3x3 + 1;
					cuenta_seguridad_3x3 <= '1';
				end if;
			else
				cont_pxl_3x3 <= cont_pxl_3x3 + 0;
				cuenta_seguridad_3x3 <= cuenta_seguridad_3x3;
			end if;
        else
            cont_pxl_3x3 <= cont_pxl_3x3 + 0;
			cuenta_seguridad_3x3 <= '0';
        end if;
    end if;
    end Process;
 
P_COMB_3X3_11X11: Process (espera_ciclo, cont_pxl_3x3, para_vecindad, pxl_num_11x11)
begin
    if espera_ciclo = '1' then --Señal que activa el contador del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
        if para_vecindad = '1' then --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3 (cuando para_vecindad = '1')
			if cont_pxl_3x3 = pxl_num_11x11 - (lado_img + 1) + 2 then  -- Cuando llega al fin de cuenta de los pixeles de una linea de 3
				new_line_3x3 <= '1'; --Se ha completado una linea de 3 pixeles (vecindad de 3x3)
				busca_hecho <= '1'; --Cada pixel del parche 3x3, para indicar que se realiza el procesamiento de ese pixel
				busca_hecho_aux <= '1';
			else
				new_line_3x3 <= '0';
				busca_hecho <= '1';
				busca_hecho_aux <= '1';
			end if;
		else
			busca_hecho <= '0';
			busca_hecho_aux <= '0';
			new_line_3x3 <= '0';
		end if;
    else
        busca_hecho <= '0';
        busca_hecho_aux <= '0';
        new_line_3x3 <= '0';
    end if;
end Process;


-- Contador de lineas (filas)
P_cont_line_3x3: Process (rst, clk)
    
begin
    if rst = c_on then
        cont_line_3x3 <= (others => '0');
    elsif clk'event and clk = '1' then
        if new_line_3x3 = '1' then  --Cuando se empieza una nueva línea y se envia un nuevo pixel
             if cuenta_seguridad_line_3x3 = '0' then --Señal para asegurarnos que solo realiza una cuenta aunque se pierdan ciclos por la maquina de estados        
				if cont_line_3x3 = fin_cont_line_3x3 then --Cuando se han contado 3 lineas
                    cont_line_3x3 <= (others => '0');
					cuenta_seguridad_line_3x3 <= '1';
                else
                    cont_line_3x3 <= cont_line_3x3 + 1;
					cuenta_seguridad_line_3x3 <= '1';
                end if;
			else
				cont_line_3x3 <= cont_line_3x3 + 0;
				cuenta_seguridad_line_3x3 <= cuenta_seguridad_line_3x3;
            end if;
		else
			cont_line_3x3 <= cont_line_3x3;
			cuenta_seguridad_line_3x3 <= '0';
        end if;
	end if;
end Process;    
    
line_num_3x3 <= STD_LOGIC_VECTOR (cont_line_3x3); -- Indica la linea en la que se encuentra el parche 3x3 dentro de la vecindad de la ROM3

--Asignamos el valor correspondiente a cada pixel del parche 3x3 dentro de la vecindad 11x11 según el número de fila
pxl_num_3x3_aux <= cont_pxl_3x3 + (("00000"&cont_line_3x3) * lado_img); --Dirección de memoria del pixel del parche 3x3 del pixel de la vecindad 11x11 de la ROM3


--Proceso que indica cuando se ha terminado de analizar todos los pixeles de una vecindad
P_comb_fin_vecindad: Process (cont_line_11x11, cont_pxl_11x11, addr3_aux)
begin
    if cont_line_11x11 = fin_cont_line_11x11 and cont_pxl_11x11 = (addr3_aux - lado_img * 5 - 5) + 10 then --Cuando se llega al último pixel de la vecindad
        fin_vecindad <= '1'; --Señal que indica fin de una vecindad
    else
        fin_vecindad <= '0';
    end if;
end process;

end Behavioral;