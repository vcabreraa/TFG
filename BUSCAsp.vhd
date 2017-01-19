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
    Port ( compara_hecho : out STD_LOGIC;
           fin_vecindad : out STD_LOGIC;
           pixel_num_11x11 : out std_logic_vector (c_2dim_img - 1 downto 0);
           busca_hecho_maqestados : in STD_LOGIC;
           espera_ciclo : in STD_LOGIC;
           busca_hecho : out STD_LOGIC;
           busca1_hecho_maqestados : in STD_LOGIC;
           busca1_hecho : out STD_LOGIC;
           para_vecindad: in STD_LOGIC; --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
           para_vecindad_maqestados: out STD_LOGIC;
           addr3 : in STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
           addr1 : in STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
           addr1_3x3 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
           pxl_num_3x3 : out STD_LOGIC_VECTOR (c_2dim_img-1 downto 0);
           clk: in STD_LOGIC;
           rst: in STD_LOGIC;
           compara : in STD_LOGIC);
           
end BUSCAsp;

architecture Behavioral of BUSCAsp is

signal addr1_3x3_aux : unsigned (c_2dim_img - 1 downto 0);
signal pxl_num_3x3_aux : unsigned (c_2dim_img-1 downto 0);

--Señales para parche 3x3 de la imagen 1
signal addr1_aux: unsigned (c_2dim_img - 1 downto 0);

--Señales para vecindad 11x11 de la imagen 3
signal addr3_11x11 : unsigned (c_2dim_img - 1 downto 0);
signal addr3_aux: unsigned (c_2dim_img - 1 downto 0);

--Señales para parche 3x3 dentro de la vecindad
signal addr3_3x3 : unsigned (c_2dim_img - 1 downto 0);

-- Contador de pixeles 11x11
signal cont_pxl_11x11 : unsigned (c_2dim_img - 1 downto 0);
signal new_line_11x11 : STD_LOGIC;

-- Contador de lineas 11x11
signal cont_line_11x11 : unsigned (4 downto 0);
constant fin_cont_line_11x11: natural := 10;

-- Contador de pixeles 3x3 dentro del 11x11
signal cont_pxl_3x3 : unsigned (c_2dim_img - 1 downto 0);
signal new_line_3x3 : STD_LOGIC;

-- Contador de lineas 3x3 dentro del 11x11
signal cont_line_3x3 : unsigned (1 downto 0);
constant fin_cont_line_3x3: natural := 2;

signal pxl_num_11x11 : unsigned (c_2dim_img - 1 downto 0);
signal line_num_3x3 : std_Logic_vector (1 downto 0);

signal new_line_3x3_1 : std_Logic;
signal cont_pxl_3x3_1 : unsigned (c_2dim_img - 1 downto 0);
signal cont_line_3x3_1 : unsigned (1 downto 0);

begin

addr1_aux <= unsigned (addr1);
addr3_aux <= unsigned (addr3);


addr1_3x3 <= STD_lOGIC_VECTOR (addr1_3x3_aux);
pxl_num_3x3 <= STD_lOGIC_VECTOR (pxl_num_3x3_aux);


----------------- Parche 3x3 de la imagen 1 -------------
-- Contador de los píxeles de cada línea 
P_cont_pxl_3x3_1: Process(rst,clk)

    begin
    if rst = c_on then
        cont_pxl_3x3_1 <= (others => '0');
    elsif clk'event and clk = '1' then
    cont_pxl_3x3_1 <= addr1_aux - (lado_img + 1) - 2; --el cilo de reloj de retraso de la maq de estados que yo supongo
        if compara = '1' then
            if busca1_hecho_maqestados = '0' then
                if cont_pxl_3x3_1 = addr1_aux - (lado_img + 1) + 2 then  -- Cuando llega al fin de cuenta  
                    cont_pxl_3x3_1 <= addr1_aux - (lado_img + 1);
                else
                    cont_pxl_3x3_1 <= cont_pxl_3x3_1 + 1;
                end if;
             else 
                cont_pxl_3x3_1 <= cont_pxl_3x3_1 + 0;
        end if;
    end if;
end if;
end Process;
    
P_comb_cont_pxl_3x3_1: Process (compara, busca1_hecho_maqestados, cont_pxl_3x3_1)
begin
if compara = '1' then
      if busca1_hecho_maqestados = '0' then
             if cont_pxl_3x3_1 = addr1_aux - (lado_img + 1) + 2 then
                    busca1_hecho <= '1';
                    new_line_3x3_1 <= '1';
             else
                    busca1_hecho <= '1';
                    new_line_3x3_1 <= '0';
                end if;
             else 
                busca1_hecho <= '0';
                new_line_3x3_1 <= '0';
        end if;
    end if;

end Process;

    
-- Contador de lineas (filas)
P_cont_line_3x3_1: Process (rst, clk)
        
            begin
            if rst = c_on then
                cont_line_3x3_1 <= (others => '0');
            elsif clk'event and clk = '1' then
                if new_line_3x3_1 = '1' then  --Cuando se empieza una nueva línea y se envia un nuevo pixel
                    if cont_line_3x3_1 = fin_cont_line_3x3 then
                        cont_line_3x3_1 <= (others => '0');
                    else
                        cont_line_3x3_1 <= cont_line_3x3_1 + 1;
                    end if;
                end if;
            end if;
            end Process;    
    
addr1_3x3_aux <= cont_pxl_3x3_1 + ("0000000"&cont_line_3x3_1) * lado_img;


--  ---------------vecindad 11x11 de la imagen 3----------------   
-- Contador de los pixeles de cada linea 
P_cont_pxl_11x11: Process(rst,clk)
  
      begin
      if rst = c_on then
          cont_pxl_11x11 <= (others => '0');
      elsif clk'event and clk = '1' then
      cont_pxl_11x11 <= addr3_aux - lado_img * 5 - 7; --porque tarda un ciclo de reloj en el para_vecindad y otro ciclo de reloj para el busca_hecho
      if compara = '1' then
        if para_vecindad = '0' then
              if cont_pxl_11x11 = (addr3_aux - lado_img * 5 - 5) + 10 then  -- Cuando llega al fin de cuenta 
                  cont_pxl_11x11 <= addr3_aux - lado_img * 5 -5;
--              elsif cont_pxl_11x11 = (addr3_aux - lado_img * 5 - 5) + 9 then  -- para poner new_line a 1 y como tarda un ciclo de reloj en salir el valore real del pxl multiplicado por la fila, poh eso
--                    cont_pxl_11x11 <= cont_pxl_11x11 + 1;
              else
                  cont_pxl_11x11 <= cont_pxl_11x11 + 1;
              end if;
         else
            cont_pxl_11x11 <= cont_pxl_11x11 + 0;
         end if;
      end if;
    end if;
      end Process;
   
p_comb: Process (compara, para_vecindad, cont_pxl_11x11)
begin
if compara = '1' then
        if para_vecindad = '0' then
              if cont_pxl_11x11 = (addr3_aux - lado_img * 5 - 5) + 10 then  -- para poner new_line a 1 y como tarda un ciclo de reloj en salir el valore real del pxl multiplicado por la fila, poh eso
                    new_line_11x11 <= '1';
                    para_vecindad_maqestados <= '1';
              else
                  new_line_11x11 <= '0';
                  para_vecindad_maqestados <= '1'; --Cada pixel que encuentra va a parar, para hacer su parche 3x3
              end if;
         else
            new_line_11x11 <= '0';
            para_vecindad_maqestados <= '0';
         end if;
      end if;

      end Process;

      
  -- Contador de lineas (filas)
P_cont_line_11x11: Process (rst, clk)
      
          begin
          if rst = c_on then
              cont_line_11x11 <= (others => '0');
          elsif clk'event and clk = '1' then
              if new_line_11x11 = '1' then  --Cuando se empieza una nueva línea y se envia un nuevo pixel
                  if cont_line_11x11 = fin_cont_line_11x11 then
                      cont_line_11x11 <= (others => '0');
                  else
                      cont_line_11x11 <= cont_line_11x11 + 1;
                  end if;
              end if;
       end if;
          end Process;    

--Según el número de línea asignamos un valor a cada píxel, que será la dirección del pixel de la imagen 3
pxl_num_11x11 <= cont_pxl_11x11 + (("0000"&cont_line_11x11) * lado_img);



-------------Parche de 3x3 de cada pixel de la vecindad 11x11-------
--Proceso que cuenta los pixeles
P_cont_pxl_3x3: Process(rst,clk)

    begin
    if rst = c_on then
        cont_pxl_3x3 <= (others => '0');
    elsif clk'event and clk = '1' then
--        if espera_ciclo = '1' then
--        if clk'event and clk = '0' then
--            if clk'event and clk = '1' then
            cont_pxl_3x3 <= pxl_num_11x11 - (lado_img + 1); --Los ciclos de reloj de retraso de señal de la maq de estados (cicloRLJ)
            if espera_ciclo = '1' then
                if para_vecindad = '1' then
                    if busca_hecho_maqestados = '0' then
                        if cont_pxl_3x3 = pxl_num_11x11 - (lado_img + 1) + 2 then
                            cont_pxl_3x3 <= pxl_num_11x11 - (lado_img + 1);
                        else
                            cont_pxl_3x3 <= cont_pxl_3x3 + 1;
                        end if;
                     else
                        cont_pxl_3x3 <= cont_pxl_3x3 + 0;
                     end if;
                end if;
--            end if;
        end if;
    end if;
    end Process;
 
P_COMB_3X3_11X11: Process (busca_hecho_maqestados, cont_pxl_3x3)
begin
--if para_vecindad = '1' then
            if busca_hecho_maqestados = '0' then
                if cont_pxl_3x3 = pxl_num_11x11 - (lado_img + 1) + 2 then  -- Cuando llega al fin de cuenta 
                    new_line_3x3 <= '1';
                    busca_hecho <= '1';
                else
                    new_line_3x3 <= '0';
                    busca_hecho <= '1';
                end if;
             else
                busca_hecho <= '0';
                new_line_3x3 <= '0';
             end if;
       -- end if;
    end Process;


-- Contador de lineas (filas)
P_cont_line_3x3: Process (rst, clk)
    
        begin
        if rst = c_on then
            cont_line_3x3 <= (others => '0');
        elsif clk'event and clk = '1' then
            if new_line_3x3 = '1' then  --Cuando se empieza una nueva línea y se envia un nuevo pixel
                if cont_line_3x3 = fin_cont_line_3x3 then
                    cont_line_3x3 <= (others => '0');
                else
                    cont_line_3x3 <= cont_line_3x3 + 1;
                end if;
            end if;
        end if;
        end Process;    
    
line_num_3x3 <= STD_LOGIC_VECTOR (cont_line_3x3); -- Indica la linea en la que se encuentra

--Asignamos el valor correspondiente a cada pixel del parche 3x3 dentro de la vecindad 11x11 según el número de fila
pxl_num_3x3_aux <= cont_pxl_3x3 + (("0000000"&cont_line_3x3) * lado_img);

p_comb_compara_hecho: Process (line_num_3x3, cont_pxl_3x3)
begin
     if line_num_3x3 = "10" and cont_pxl_3x3 = pxl_num_11x11 - (lado_img + 1) + 2 then
            compara_hecho <= '1'; --Los parches estarán hechos cuando llegue al 9 píxel del parche 3x3 de la vecindad 11x11
        else
            compara_hecho <= '0';
     end if;
end process;

P_comb_fin_vecindad: Process (cont_line_11x11, cont_pxl_11x11, line_num_3x3, cont_pxl_3x3)
begin
    if cont_line_11x11 = fin_cont_line_11x11 and cont_pxl_11x11 = (addr3_aux - lado_img * 5 - 5) + 9 and line_num_3x3 = "10" and cont_pxl_3x3 = pxl_num_11x11 - (lado_img + 1) + 2 then
        fin_vecindad <= '1';
    else
        fin_vecindad <= '0';
    end if;
end process;

pixel_num_11x11 <= std_logic_vector (pxl_num_11x11);

end Behavioral;