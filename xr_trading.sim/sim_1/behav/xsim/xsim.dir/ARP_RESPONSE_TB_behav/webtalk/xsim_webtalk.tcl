webtalk_init -webtalk_dir /home/joe/xr_trading/xr_trading.sim/sim_1/behav/xsim/xsim.dir/ARP_RESPONSE_TB_behav/webtalk/
webtalk_register_client -client project
webtalk_add_data -client project -key date_generated -value "Fri Oct 18 13:33:37 2019" -context "software_version_and_target_device"
webtalk_add_data -client project -key product_version -value "XSIM v2019.1.2 (64-bit)" -context "software_version_and_target_device"
webtalk_add_data -client project -key build_version -value "2615518" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_platform -value "LIN64" -context "software_version_and_target_device"
webtalk_add_data -client project -key registration_id -value "" -context "software_version_and_target_device"
webtalk_add_data -client project -key tool_flow -value "xsim_vivado" -context "software_version_and_target_device"
webtalk_add_data -client project -key beta -value "FALSE" -context "software_version_and_target_device"
webtalk_add_data -client project -key route_design -value "FALSE" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_family -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_device -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_package -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_speed -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key random_id -value "fcaf4880-62c4-47c0-999e-9f748b83960b" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_id -value "832a455316324ba59b0b5d871d2ca7a3" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_iteration -value "100" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_name -value "Ubuntu" -context "user_environment"
webtalk_add_data -client project -key os_release -value "Ubuntu 18.04.3 LTS" -context "user_environment"
webtalk_add_data -client project -key cpu_name -value "Intel(R) Core(TM) i5-5287U CPU @ 2.90GHz" -context "user_environment"
webtalk_add_data -client project -key cpu_speed -value "3140.915 MHz" -context "user_environment"
webtalk_add_data -client project -key total_processors -value "1" -context "user_environment"
webtalk_add_data -client project -key system_ram -value "16.000 GB" -context "user_environment"
webtalk_register_client -client xsim
webtalk_add_data -client xsim -key Command -value "xsim" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key trace_waveform -value "true" -context "xsim\\usage"
webtalk_add_data -client xsim -key runtime -value "1 us" -context "xsim\\usage"
webtalk_add_data -client xsim -key iteration -value "1" -context "xsim\\usage"
webtalk_add_data -client xsim -key Simulation_Time -value "0.04_sec" -context "xsim\\usage"
webtalk_add_data -client xsim -key Simulation_Memory -value "133916_KB" -context "xsim\\usage"
webtalk_transmit -clientid 2375330661 -regid "" -xml /home/joe/xr_trading/xr_trading.sim/sim_1/behav/xsim/xsim.dir/ARP_RESPONSE_TB_behav/webtalk/usage_statistics_ext_xsim.xml -html /home/joe/xr_trading/xr_trading.sim/sim_1/behav/xsim/xsim.dir/ARP_RESPONSE_TB_behav/webtalk/usage_statistics_ext_xsim.html -wdm /home/joe/xr_trading/xr_trading.sim/sim_1/behav/xsim/xsim.dir/ARP_RESPONSE_TB_behav/webtalk/usage_statistics_ext_xsim.wdm -intro "<H3>XSIM Usage Report</H3><BR>"
webtalk_terminate
