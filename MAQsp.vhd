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
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           dout2 : in STD_LOGIC;
           fin_compara : in STD_LOGIC;
           busca1_hecho : in STD_LOGIC;
           busca_hecho : in STD_LOGIC;
           para_vecindad_maqestados : in STD_LOGIC;
           compara_hecho : in STD_LOGIC;
           fin_vecindad : in STD_LOGIC;
           compara : out STD_LOGIC;
           para_vecindad : out STD_LOGIC;
           busca1_hecho_maqestados : out STD_LOGIC;
           espera_ciclo : out STD_LOGIC;
           asigna : out STD_LOGIC;
           busca_hecho_maqestados : out STD_LOGIC;
           para_contador : out STD_LOGIC);
end MAQsp;

architecture Behavioral of MAQsp is

  type estados is (Inic, Espera, CicloRLJ, Para, Resta, Compara2, Comprueba);
  signal estado_actual, estado_siguiente: estados;

begin

P_COMB_ESTADO: Process (estado_actual, dout2, busca1_hecho, para_vecindad_maqestados, busca_hecho, fin_compara, compara_hecho, fin_vecindad)
    begin
    
        case estado_actual is 
            when Inic =>
                if dout2 = '0' then
                    estado_siguiente <= espera;      
                else 
                    estado_siguiente <= Inic;  
                end if;
             when espera =>
                if busca1_hecho = '1' and para_vecindad_maqestados = '1' then --creo que podremos poner una de las dos señales ya que se van a dar a la vez
                    estado_siguiente <= CicloRLJ;
                else
                    estado_siguiente <= espera;
                end if;
            when CicloRLJ =>
                if busca1_hecho = '1' then 
                   estado_siguiente <= Para;
                else
                   estado_siguiente <= Para;
                end if;
            when Para =>
                if busca_hecho = '1' then
                    estado_siguiente <= Resta;
                else
                    estado_siguiente <= Resta; --PRUEBA (Para)
                end if;
            when Resta =>
                if fin_compara = '1' then
                    estado_siguiente <= Compara2;
                else
                    estado_siguiente <= Resta;
                end if;
            when Compara2 =>
                if fin_vecindad = '1' then
                   estado_siguiente <= Inic;
                elsif compara_hecho = '1' then
                    estado_siguiente <= Espera;
                else
                     estado_siguiente <= Comprueba;
                end if;
            when Comprueba =>
                if busca1_hecho = '1' and busca_hecho = '1' then --creo que podremos poner una de las dos señales ya que se van a dar a la vez
                     estado_siguiente <= Para;
                else
                     estado_siguiente <= Comprueba;
                end if;
        end case;
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
                   para_contador <= '0';
                   compara <= '0';
                   para_vecindad <= '0';
                   busca1_hecho_maqestados <= '0';
                   busca_hecho_maqestados <= '0';
                   espera_ciclo <= '0';
                   asigna <= '0';
               when espera =>
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '0';
                   busca1_hecho_maqestados <= '0';
                   busca_hecho_maqestados <= '0';
                   espera_ciclo <= '0';
                   asigna <= '0';
               when CicloRLJ =>
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '1'; --prueba
                   espera_ciclo <= '0';
                   asigna <= '0'; --A ver si funciona
               when para =>
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '1'; --prueba
                   espera_ciclo <= '1';
                   asigna <= '1';
               when Resta =>
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '1'; 
                   espera_ciclo <= '1';
                   asigna <= '0';
               when compara2 =>
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '1';
                   busca_hecho_maqestados <= '1';
                   espera_ciclo <= '1';
                   asigna <= '0';
               when comprueba =>
                   para_contador <= '1';
                   compara <= '1';
                   para_vecindad <= '1';
                   busca1_hecho_maqestados <= '0';
                   busca_hecho_maqestados <= '0';
                   espera_ciclo <= '1';
                   asigna <= '0';
           end case;
  end process;   

end Behavioral;