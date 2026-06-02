library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.keccak_pkg.all;

entity keccak_round is
    port(
        input_state: in state_array_t;
        round_index: in integer range 0 to 23;
        output_state: out state_array_t
    );
end keccak_round;

architecture behavioral of keccak_round is
    signal theta_out: state_array_t;
    signal rho_pi_out: state_array_t;
    signal chi_out: state_array_t;
    signal iota_out: std_logic_vector(63 downto 0);
    signal round_constant: std_logic_vector(63 downto 0);

begin
   round_const_inst: entity work.keccak_round_constants
        port map(
            input_round     => std_logic_vector(to_unsigned(round_index, 5)),
            output_constant => round_constant
        );

    theta_inst: entity work.theta
        port map(
            input_state  => input_state,
            output_state => theta_out
        );

    rho_pi_inst: entity work.rho_pi
        port map(
            input_state  => theta_out,
            output_state => rho_pi_out
        );

    chi_inst: entity work.chi
        port map(
            input_state  => rho_pi_out,
            output_state => chi_out
        );

    iota_inst: entity work.iota
        port map(
            input_s0       => chi_out(0),
            round_constant => round_constant,
            output_s0      => iota_out
        );

    output_state(0) <= iota_out;

    gen_lanes: for i in 1 to 24 generate
        output_state(i) <= chi_out(i);
    end generate;

end architecture behavioral;
