
set search_path ". /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/synopsys $search_path"

set target_library "slow.db fast.db typical.db"

set link_library   "* $target_library dw_foundation.sldb"

set symbol_library "generic.sdb"
set synthetic_library "dw_foundation.sldb"

set hdlin_translate_off_skip_text "TRUE"
set edifout_netlist_only  "TRUE"
set verilogout_no_tri "true"
set plot_command  "lpr -Plp"

set ref_cycle  2
set name "top"
#/*--------------------------------------------------------------*/
#/*----------------------- 1.Read files -------------------------*/
#/*--------------------------------------------------------------*/
read_file -format verilog ./${name}.v

# Top module name
current_design [get_designs ${name}]
set_operating_conditions slow
#/*--------------------------------------------------------------*/
#/*--------------- 2. Set design constraints --------------------*/
#/*--------------------------------------------------------------*/
#create_clock -period $ref_cycle [get_ports clk]
#set_dont_touch_network [get_clocks clk]

#create_clock -period $ref_cyicle [get_ports In_PW]
#set_dont_touch_network [get_clocks In_PW]

set_dont_touch [get_cells ctdc1/*]

#set_dont_touch [get_cells OA_cps1/I2]
#set_dont_touch [get_nets OA_cps1/*]


set_drive 1 [all_inputs]
set_load [load_of slow/CLKBUFX20/A] [all_outputs]
#/*--------------------------------------------------------------*/
#/*----------------- 3.Check and Link Design --------------------*/
#/*--------------------------------------------------------------*/
link
check_design
uniquify
set_fix_multiple_port_nets -all -buffer_constants
#/*--------------------------------------------------------------*/
#/*------------------------ 4.Compile ---------------------------*/
#/*--------------------------------------------------------------*/

set compile_new_boolean_structure

set_structure false

compile  -map_effort medium

check_design

set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\*cell\*" "cell"}}
define_name_rules name_rule -map {{"*-return", "myreturn"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

set verilogout_show_unconnected_pins true

#/*--------------------------------------------------------------*/
#/*----------------------- 5.Write out files --------------------*/
#/*--------------------------------------------------------------*/


write -format verilog -hierarchy -output ./${name}_syn.v

write_sdf -version 1.0 -context verilog -load_delay cell ./${name}_syn.sdf

exit
