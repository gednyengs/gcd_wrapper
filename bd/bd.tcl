proc init {cellpath otherInfo } {
    bd::mark_propagate_only [get_bd_pins $cellpath/CLK] {FREQ_HZ}
}

proc post_propagate {cellpath otherinfo } {

}

proc post_config_ip {cellpath otherInfo } {

}
