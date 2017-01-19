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
Port ( 
       busca_hecho_maqestados : in STD_LOGIC;
       rst : in STD_LOGIC;
       dout2 : in STD_LOGIC;
       clk: in STD_LOGIC;
       wea1 : out STD_LOGIC;
       fin_compara : out STD_LOGIC;
       fin_vecindad : in STD_LOGIC;
       asigna : in STD_LOGIC;
       --addr3 : in STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
       addr_esc : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0); --log2 de 9, (9 pixeles, 9 datos)
       dout1_3x3 : in STD_LOGIC_VECTOR (7 downto 0);
       pixel_num_11x11 : in std_logic_vector (c_2dim_img - 1 downto 0);
       pxl_dout3_3x3 : in STD_LOGIC_VECTOR (7 downto 0)
);
end CMPsp;

architecture Behavioral of CMPsp is

signal dout1_3x3_aux : unsigned (7 downto 0);
signal pxl_dout3_3x3_aux : unsigned (7 downto 0);

signal comp_pxl : unsigned (7 downto 0); --Resultado de la resta de los dos parches 3x3 de la imagen 1 y 3
--signal comp_pxl_abs : unsigned (3 downto 0); --Valor absoluto de la resta

signal cuenta : unsigned (3 downto 0);
signal dato_pxl_0, dato_pxl_1, dato_pxl_2, dato_pxl_3, dato_pxl_4, dato_pxl_5, dato_pxl_6, dato_pxl_7, dato_pxl_8 : unsigned (7 downto 0);
signal RESULTADO : unsigned (11 downto 0);
signal suma : STD_lOGIC;


  type estados_cmp is (Inicio, pxl1, resto_pxl);
  signal estado_actual, estado_siguiente: estados_cmp;
  
signal primer_pxl : STD_LOGIC;

signal addr_esc_aux : STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);

begin

dout1_3x3_aux <= unsigned (dout1_3x3);
pxl_dout3_3x3_aux <= unsigned (pxl_dout3_3x3);

--------MÁQUINA DE ESTADOS------

P_COMB_ESTADO2: Process (estado_actual, dout2, cuenta, fin_vecindad)
    begin
    
        case estado_actual is 
            when Inicio =>
                if dout2 = '0' then
                    estado_siguiente <= pxl1;      
                else 
                    estado_siguiente <= Inicio;  
                end if;
             when pxl1 =>
                if cuenta = 9 then 
                    estado_siguiente <= resto_pxl;
                else
                    estado_siguiente <= pxl1;
                end if;
             when resto_pxl =>
                if fin_vecindad = '1' then 
                    estado_siguiente <= inicio;
                else
                    estado_siguiente <= resto_pxl;
                end if;
           end case;
end process;

P_SEQ_FSM2: Process (Clk, Rst)
begin

        if rst = '1' then
            estado_actual <= Inicio; 
        elsif Clk'event and Clk = '1' then
            estado_actual <= estado_siguiente;
        end if;
    end process;
    
P_COM_SALIDAS2: Process (estado_actual)
 begin
       
           case estado_actual is
               when Inicio =>
                   primer_pxl <= '0';
               when pxl1 =>
                   primer_pxl <= '1';
               when resto_pxl =>
                   primer_pxl <= '0';
            end case;
  end process;
                  

--CONTADOR PARA LEER LOS 9 PIXELES PARA LAS 2 MEMORAS

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
 
    if busca_hecho_maqestados = '1' then --ya que la señal busca se da mas tarde que busca1
        if dout1_3x3_aux > pxl_dout3_3x3_aux then
            comp_pxl <= dout1_3x3_aux - pxl_dout3_3x3_aux;
        else
            comp_pxl <= pxl_dout3_3x3_aux - dout1_3x3_aux;
        end if;
    end if;
    
      if primer_pxl = '1' then
        if asigna = '1' then -- LO SIGUIENTE COMENTADO DEPENDE DE CUANDO COJA EL DATO (ciclos de reloj)
            if cuenta = 0 then
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 1 then
                dato_pxl_0 <= comp_pxl;
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 2 then
                dato_pxl_1 <= comp_pxl;
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 3 then
                dato_pxl_2 <= comp_pxl;
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 4 then
                dato_pxl_3 <= comp_pxl;
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 5 then
                dato_pxl_4 <= comp_pxl;  
                cuenta <= cuenta + 1;
                fin_compara <= '1'; 
                suma <= '0'; 
             elsif cuenta = 6 then
                dato_pxl_5 <= comp_pxl;
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 7 then
                dato_pxl_6 <= comp_pxl;
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 8 then
                dato_pxl_7 <= comp_pxl;
                cuenta <= cuenta + 1;
                fin_compara <= '1';
                suma <= '0';
             elsif cuenta = 9 then --Comentar este elsif
                dato_pxl_8 <= comp_pxl;
                cuenta <= (others => '0');
                suma <= '0'; 
                fin_compara <= '1';
             else
                suma <= '0';
                cuenta <= (others => '0');  
                fin_compara <= '0';
             end if;
           end if;
         else
                      if cuenta = 9 and busca_hecho_maqestados = '0' then
                            cuenta <= (others => '0');
                            suma <= '1'; 
                            fin_compara <= '0';
                            dato_pxl_8 <= comp_pxl;
                      else
                            cuenta <= cuenta;
                            suma <= '0';
                            fin_compara <= '0';
                            dato_pxl_8 <= (others => '0');
                      end if;
            if asigna = '1' then -- LO SIGUIENTE COMENTADO DEPENDE DE CUANDO COJA EL DATO (ciclos de reloj)
                        if cuenta = 0 then
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 1 then
                         dato_pxl_0 <= comp_pxl;
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 2 then
                         dato_pxl_1 <= comp_pxl;
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 3 then
                         dato_pxl_2 <= comp_pxl;
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 4 then
                         dato_pxl_3 <= comp_pxl;
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 5 then
                         dato_pxl_4 <= comp_pxl;  
                         cuenta <= cuenta + 1;
                         fin_compara <= '1'; 
                         suma <= '0'; 
                      elsif cuenta = 6 then
                         dato_pxl_5 <= comp_pxl;
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 7 then
                         dato_pxl_6 <= comp_pxl;
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 8 then
                         dato_pxl_7 <= comp_pxl;
                         cuenta <= cuenta + 1;
                         fin_compara <= '1';
                         suma <= '0';
                      elsif cuenta = 9 then
                         dato_pxl_8 <= comp_pxl;
                         cuenta <= (others => '0');
                         suma <= '0'; 
                         fin_compara <= '1';
                      else
                         suma <= '0';
                         cuenta <= (others => '0');  
                         fin_compara <= '0';
                      end if;
        end if;
  end if;

end if;
end process;
                
   
p2: process (rst, clk)
   begin

 if rst = '1' then
    RESULTADO <= (others => '0');
 elsif clk'event and clk = '1' then
   if suma = '1' then 
      RESULTADO <= ("0000"&dato_pxl_0) + ("0000"&dato_pxl_1) + ("0000"&dato_pxl_2) + ("0000"&dato_pxl_3) + ("0000"&dato_pxl_4) + ("0000"&dato_pxl_5) + ("0000"&dato_pxl_6) + ("0000"&dato_pxl_7) + ("0000"&dato_pxl_8) ;
   else
      RESULTADO <= (others => '0');
   end if;
end if;
   
end process;

p3: process (resultado)
begin

    if RESULTADO > c_umbral then --100 por ejemplo (meter constante en el paquete)
        wea1 <= '1';
    else 
        wea1 <= '0';
    end if;                   
end process; 

p4: process (cuenta)
begin

if cuenta = 6 then                        
    addr_esc_aux <= pixel_num_11x11;
else
    addr_esc_aux <= addr_esc_aux;
end if;
end process;

addr_esc <= addr_esc_aux;
--addr_esc <= pixel_num_11x11;

end Behavioral;