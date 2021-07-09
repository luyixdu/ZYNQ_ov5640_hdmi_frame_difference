
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/rgb2lcd_v1_4.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "REDDEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "GREENDEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BULEDEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VID_IN_DATA_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.VID_OUT_DATA_WIDTH { PARAM_VALUE.VID_OUT_DATA_WIDTH PARAM_VALUE.REDDEPTH PARAM_VALUE.GREENDEPTH PARAM_VALUE.BULEDEPTH } {
	# Procedure called to update VID_OUT_DATA_WIDTH when any of the dependent parameters in the arguments change
	
	set VID_OUT_DATA_WIDTH ${PARAM_VALUE.VID_OUT_DATA_WIDTH}
	set REDDEPTH ${PARAM_VALUE.REDDEPTH}
	set GREENDEPTH ${PARAM_VALUE.GREENDEPTH}
	set BULEDEPTH ${PARAM_VALUE.BULEDEPTH}
	set values(REDDEPTH) [get_property value $REDDEPTH]
	set values(GREENDEPTH) [get_property value $GREENDEPTH]
	set values(BULEDEPTH) [get_property value $BULEDEPTH]
	set_property value [gen_USERPARAMETER_VID_OUT_DATA_WIDTH_VALUE $values(REDDEPTH) $values(GREENDEPTH) $values(BULEDEPTH)] $VID_OUT_DATA_WIDTH
}

proc validate_PARAM_VALUE.VID_OUT_DATA_WIDTH { PARAM_VALUE.VID_OUT_DATA_WIDTH } {
	# Procedure called to validate VID_OUT_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.BULEDEPTH { PARAM_VALUE.BULEDEPTH } {
	# Procedure called to update BULEDEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BULEDEPTH { PARAM_VALUE.BULEDEPTH } {
	# Procedure called to validate BULEDEPTH
	return true
}

proc update_PARAM_VALUE.GREENDEPTH { PARAM_VALUE.GREENDEPTH } {
	# Procedure called to update GREENDEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GREENDEPTH { PARAM_VALUE.GREENDEPTH } {
	# Procedure called to validate GREENDEPTH
	return true
}

proc update_PARAM_VALUE.REDDEPTH { PARAM_VALUE.REDDEPTH } {
	# Procedure called to update REDDEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REDDEPTH { PARAM_VALUE.REDDEPTH } {
	# Procedure called to validate REDDEPTH
	return true
}

proc update_PARAM_VALUE.VID_IN_DATA_WIDTH { PARAM_VALUE.VID_IN_DATA_WIDTH } {
	# Procedure called to update VID_IN_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VID_IN_DATA_WIDTH { PARAM_VALUE.VID_IN_DATA_WIDTH } {
	# Procedure called to validate VID_IN_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.VID_IN_DATA_WIDTH { MODELPARAM_VALUE.VID_IN_DATA_WIDTH PARAM_VALUE.VID_IN_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VID_IN_DATA_WIDTH}] ${MODELPARAM_VALUE.VID_IN_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.REDDEPTH { MODELPARAM_VALUE.REDDEPTH PARAM_VALUE.REDDEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REDDEPTH}] ${MODELPARAM_VALUE.REDDEPTH}
}

proc update_MODELPARAM_VALUE.GREENDEPTH { MODELPARAM_VALUE.GREENDEPTH PARAM_VALUE.GREENDEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GREENDEPTH}] ${MODELPARAM_VALUE.GREENDEPTH}
}

proc update_MODELPARAM_VALUE.BULEDEPTH { MODELPARAM_VALUE.BULEDEPTH PARAM_VALUE.BULEDEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BULEDEPTH}] ${MODELPARAM_VALUE.BULEDEPTH}
}

proc update_MODELPARAM_VALUE.VID_OUT_DATA_WIDTH { MODELPARAM_VALUE.VID_OUT_DATA_WIDTH PARAM_VALUE.VID_OUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VID_OUT_DATA_WIDTH}] ${MODELPARAM_VALUE.VID_OUT_DATA_WIDTH}
}

