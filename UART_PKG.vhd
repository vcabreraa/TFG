--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package UART_PKG is

	--------------------- declaracion de constantes ----------------------------------
	-- c_on: indica el tipo de logica de los pulsadores, interruptores y LEDS
	-- si es '1' indica que es logica directa -> PLACA NEXYS2
	-- si es '0' indica que es logica directa -> PLACA XUPV2P
	constant c_on : std_logic := '1'; -- NEXYS2
	constant c_off : std_logic := not c_on;
	
	-- c_freq_clk: indica la frecuencia a la que funciona el reloj de la placa
	-- para la Nexys2 el reloj va a 50MHz -> 5*10**7;
	-- para la XUPV2P el reloj va a 100MHz -> 10**8;
	constant c_freq_clk : natural := 10**8; -- NEXYS4
	
	constant c_period_ns_clk : natural:= 10**9/c_freq_clk;
	
	-- c_baud: indica los baudios a los que transmite la UART, valores
	-- tipicos son 9600, 19200, 57600, 115200
	-- Este valor depende de la conexion establecida con la computadora
	constant c_baud : natural := 115200;

	constant c_period_ns_baud : natural := 10**9/c_baud;
	
	-- c_fin_cont_baud: fin cuenta para bloque divisor de frequencia
	constant c_fin_cont_baud : natural := c_freq_clk/c_baud - 1;
	
	-- c_fin_cont_3ms: fin cuenta para contar 300ms, necesario para el
	-- bloque anti-rebotes, ya que la Nexys no lo incluye en la placa.
	-- c_freq_clk/(1/(300*10**(-3))) - 1 
	constant c_fin_cont_3ms : natural := (15000000) - 1;
	
	-- c_bits: indica el numero de bits de datos sin incluir bit inicio,
	-- bit final o bit paridad.
	-- Este valor depende de la conexion establecida con la computadora:
	-- para enviar 8 bits de datos, c_bits sera 7 (para el contador de bits
	-- contamos de 0 a 7)
	constant c_bits : natural := 7;

	-------------------- Funcion div_redondea --------------------------------
	-- Descripcion: funcion que divide redondeando al entero mas cercano,
	-- evitando el problema del operador "/" que trunca al entero inferior
	-- inmediato.
	-- Entradas:
	-- * dividendo: numero entero positivo que queremos dividir
	-- * divisor: numero entero positivo entre el que queremos dividir
	-- Salida:
	-- * devuelve el resultado de dividir redondeando al entero mas cercano
	function div_redondea (dividendo, divisor : natural) return integer;
	
	--------------------------- funcion: log2i --------------------------------------
	-- Descripcion: funcion que calcula el logaritmo en base 2 de un numero entero
	-- positivo. No calcula decimales, devuelve el entero mas cercano
	-- al resultado - por eso la i (de integer) del nombre log2i.
	-- P. ej: log2i(7) = 2, log2i(8) = 3.
	-- Entradas:
	-- * valor: numero entero positivo del que queremos calcular el logaritmo en
	-- Salida:
	-- * devuelve el logaritmo truncado al mayor entero menor o igual que el resultado
	function log2i (valor : positive) return natural;

	-- c_nb_cont_baud: indica el numero de bits (nb) menos 1 necesarios para 
	-- representar c_fin_cont_baud
	constant c_nb_cont_baud : natural := log2i(c_fin_cont_baud);
	
	-- c_nb_cont_bits: indica el numero de bits (nb) menos 1 necesarios para 
	-- representar c_bits
	constant c_nb_cont_bits : natural := log2i(c_bits);

	-- c_nb_cont_3ms: indica el numero de bits (nb) menos 1 necesarios para 
	-- representar c_fin_cont_3ms
	constant c_nb_cont_3ms : natural := log2i(c_fin_cont_3ms);

	constant c_cero	: string := " cero ";
	constant c_uno		: string := " uno ";
	constant c_dos		: string := " dos ";
	constant c_tres 	: string := " tres ";
	constant c_cuatro	: string := " cuatro ";
	constant c_cinco	: string := " cinco ";
	constant c_seis	: string := " seis ";
	constant c_siete	: string := " siete ";
	constant c_ocho	: string := " ocho ";
	constant c_nueve	: string := " nueve ";
	constant c_otro	: string := " otro ";

	-------------------- Funcion a_texto -------------------------------------
	-- Descripcion: funcion que recibe un numero entero y devuelve la
	-- transcripcion en texto de ese numero.
	-- Entradas:
	-- * indice: numero entero que queremos pasar a texto
	-- Salida:
	-- * devuelve el numero escrito en texto (string). Si el entero es distinto
	-- de 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, se devuelve la cadena " otro "
	function a_texto (indice : integer) return string;

end UART_PKG;

package body UART_PKG is
	-------------------- Funcion div_redondea --------------------------------
	function div_redondea (dividendo, divisor : natural) return integer is
		variable division, resto : integer;
	begin
		division := dividendo/divisor;
		resto := dividendo rem divisor;
		if (resto > (divisor/2)) then
			division := division + 1;
		end if;
		return (division);
	end function;

	-------------------- Funcion log2i ---------------------------------------
	-- Ejemplos de funcionamiento (valor = 6, 7 y 8)
	--  * valor = 6 				|  * valor = 7					|  * valor = 8
	-- 	  tmp = 6/2 = 3 		| 		  tmp = 7/2 = 3 		| 		  tmp = 8/2 = 4
	-- 	  log2 = 0 				| 		  log2 = 0 				| 		  log2 = 0
	-- 	- loop 0: tmp 3 > 0 	| 		- loop 0: tmp 3>0 	| 		- loop 0: tmp 4>0
	-- 	  tmp = 3/2 = 1 		| 		  tmp = 3/2 = 1 		| 		  tmp = 4/2 = 2
	-- 	  log2 = 1 				| 		  log2 = 1 				| 		  log2 = 1
	-- 	- loop 1: tmp 1 > 0 	| 		- loop 1: tmp 1 > 0 	| 		- loop 1: tmp 2 > 0
	-- 	  tmp = 1/2 = 0 		| 		  tmp = 1/2 = 0 		| 		  tmp = 2/2 = 1
	-- 	  log2 = 2 				| 		  log2 = 2 				| 		  log2 = 2
	-- 	- end loop: tmp = 0 	| 		- end loop: tmp = 0 	| 		- loop 2: tmp 1 > 0
	--  * return log2 = 2 		|  * return log2 = 2 		| 		  temp = 1/2 = 0
	-- 																	| 		  log2 = 3
	--																		| 		- end loop: tmp = 0
	-- 																	|  * return log2 = 3
	function log2i (valor : positive) return natural is
		variable tmp, log2: natural;
	begin
		tmp := div_redondea(valor, 2); -- division entera, redondea al entero inmediatamente menor o =
		log2 := 0;
		while (tmp /= 0) loop
			tmp := div_redondea(tmp, 2);
			log2 := log2 + 1;
		end loop;
		return log2;
	end function log2i;

	-------------------- Funcion a_texto -------------------------------------
	function a_texto (indice : integer) return string is
	begin
		case indice is
			when 0 =>
				return c_cero;
			when 1 =>
				return c_uno;
			when 2 =>
				return c_dos;
			when 3 =>
				return c_tres;
			when 4 =>
				return c_cuatro;
			when 5 =>
				return c_cinco;
			when 6 =>
				return c_seis;
			when 7 =>
				return c_siete;
			when 8 =>
				return c_ocho;
			when 9 =>
				return c_nueve;
			when others =>
				return c_otro;
		end case;
	end function a_texto;
end UART_PKG;

