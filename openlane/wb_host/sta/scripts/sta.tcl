# SPDX-FileCopyrightText:  2021 , Dinesh Annayya
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>
#

set ::env(LIB_FASTEST) "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib"
set ::env(LIB_TYPICAL) "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set ::env(LIB_SLOWEST) "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib"
set ::env(DESIGN_NAME) "wb_host"
set ::env(BASE_SDC_FILE) $::env(STA_MODE).sdc
set ::env(SYNTH_DRIVING_CELL) "sky130_fd_sc_hd__inv_8"
set ::env(SYNTH_DRIVING_CELL_PIN) "Y"
set ::env(SYNTH_CAP_LOAD) "17.65"
set ::env(WIRE_RC_LAYER) "met1"

#To disable empty filler cell black box get created
#set link_make_black_boxes 0


set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um
define_corners wc bc tt
read_liberty -corner bc $::env(LIB_FASTEST)
read_liberty -corner wc $::env(LIB_SLOWEST)
read_liberty -corner tt $::env(LIB_TYPICAL)

read_lib  -corner tt   ../lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib
read_lib  -corner tt   ../lib/sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib

read_verilog netlist/wb_host.v

link_design  $::env(DESIGN_NAME)

read_spef ../../../spef/wb_host.spef  


read_sdc -echo $::env(BASE_SDC_FILE)

# check for missing constraints
check_setup  -verbose > reports/$::env(STA_MODE)/unconstraints.rpt

set_operating_conditions -analysis_type single
# Propgate the clock
set_propagated_clock [all_clocks]

report_tns
report_wns
#report_power 
#
echo "################ CORNER : WC (MAX) TIMING Report ###################"                                              > reports/$::env(STA_MODE)/timing_ss_max.rpt
report_checks -unique -slack_max -0.0 -path_delay max -group_count 100          -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbm_clk_i   -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbs_clk_i   -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  lbist_clk   -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_max.rpt
report_checks                         -path_delay max                           -corner wc                              >> reports/$::env(STA_MODE)/timing_ss_max.rpt

echo "################ CORNER : WC (MIN) TIMING Report ###################"                                              > reports/$::env(STA_MODE)/timing_ss_min.rpt
report_checks -unique -slack_max -0.0 -path_delay min -group_count 100          -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbm_clk_i   -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbs_clk_i   -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  lbist_clk   -corner wc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ss_min.rpt
report_checks                         -path_delay min                           -corner wc                              >> reports/$::env(STA_MODE)/timing_ss_min.rpt

echo "################ CORNER : BC (MAX) TIMING Report ###################"                                              > reports/$::env(STA_MODE)/timing_ff_max.rpt
report_checks -unique -slack_max -0.0 -path_delay max -group_count 100          -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbm_clk_i   -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbs_clk_i   -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  lbist_clk   -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_max.rpt
report_checks                         -path_delay max                           -corner bc                              >> reports/$::env(STA_MODE)/timing_ff_max.rpt

echo "################ CORNER : BC (MIN) TIMING Report ###################"                                              > reports/$::env(STA_MODE)/timing_ff_min.rpt
report_checks -unique -slack_max -0.0 -path_delay min -group_count 100          -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbm_clk_i   -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbs_clk_i   -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  lbist_clk   -corner bc  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_ff_min.rpt
report_checks                         -path_delay min                           -corner bc                              >> reports/$::env(STA_MODE)/timing_ff_min.rpt


echo "################ CORNER : TT (MAX) TIMING Report ###################"                                              > reports/$::env(STA_MODE)/timing_tt_max.rpt
report_checks -unique -slack_max -0.0 -path_delay max -group_count 100          -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbm_clk_i   -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbs_clk_i   -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  lbist_clk   -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_max.rpt
report_checks                         -path_delay max                           -corner tt                              >> reports/$::env(STA_MODE)/timing_tt_max.rpt

echo "################ CORNER : TT (MIN) TIMING Report ###################"                                              > reports/$::env(STA_MODE)/timing_tt_min.rpt
report_checks -unique -slack_max -0.0 -path_delay min -group_count 100          -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbm_clk_i   -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbs_clk_i   -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  lbist_clk   -corner tt  -format full_clock_expanded >> reports/$::env(STA_MODE)/timing_tt_min.rpt
report_checks                         -path_delay min                           -corner tt                              >> reports/$::env(STA_MODE)/timing_tt_min.rpt


report_checks -path_delay min_max 

exit
