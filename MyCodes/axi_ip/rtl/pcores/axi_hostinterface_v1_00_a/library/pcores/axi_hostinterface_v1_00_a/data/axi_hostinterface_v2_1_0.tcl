
#uses "xillib.tcl"

proc calc_baseadr_dbuf1 { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseDynBuf0"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_DynBuf0"]
    set Incr_Addr_Size [format 0x%x [expr $User_Size * 1024]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_Errcntr { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseDynBuf1"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_DynBuf1"]
    set Incr_Addr_Size [format 0x%x [expr $User_Size * 1024]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_TxNmtQ { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseErrCntr"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_B_ErrorCounter"]
    set Incr_Addr_Size [format 0x%x $User_Size]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_TxGenQ { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseTxNmtQ"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_TxNmtQ"]
    set Incr_Addr_Size [format 0x%x [expr {$User_Size * 1024} + 16]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_TxSynQ { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseTxGenQ"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_TxGenQ"]
    set Incr_Addr_Size [format 0x%x [expr {$User_Size * 1024} + 16]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_TxVetQ { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseTxSynQ"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_TxSynQ"]
    set Incr_Addr_Size [format 0x%x [expr {$User_Size * 1024} + 16]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_RxVetQ { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseTxVetQ"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_TxVetQ"]
    set Incr_Addr_Size [format 0x%x [expr {$User_Size * 1024} + 16]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_K2UQ { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseRxVetQ"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_RxVetQ"]
    set Incr_Addr_Size [format 0x%x [expr {$User_Size * 1024} + 16]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_U2KQ { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseK2UQ"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_K2UQ"]
    set Incr_Addr_Size [format 0x%x [expr {$User_Size * 1024} + 16]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_Tpdo { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseU2KQ"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_KB_U2KQ"]
    set Incr_Addr_Size [format 0x%x [expr {$User_Size * 1024} + 16]]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_Rpdo { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseTpdo"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_B_Tpdo"]
    set Incr_Addr_Size [format 0x%x $User_Size ]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_baseadr_Res { param_handle} {
    set mhsinst     [xget_hw_parent_handle $param_handle]
  set Base_Addr   [xget_hw_parameter_value $mhsinst "gBaseRpdo"]
  set User_Size   [xget_hw_parameter_value $mhsinst "Size_B_Rpdo"]
    set Incr_Addr_Size [format 0x%x $User_Size ]
  set Updated_Addr [format 0x%x [expr $Base_Addr + $Incr_Addr_Size]]
    return $Updated_Addr
}

proc calc_total_memory { param_handle} {
  set mhsinst     [xget_hw_parent_handle $param_handle]
  set listGuiParam [list "Size_KB_DynBuf0" "Size_KB_DynBuf1" "Size_B_ErrorCounter" "Size_KB_TxNmtQ" "Size_KB_TxGenQ" "Size_KB_TxSynQ" "Size_KB_TxVetQ" "Size_KB_RxVetQ" "Size_KB_K2UQ" "Size_KB_U2KQ" "Size_B_Tpdo" "Size_B_Rpdo"]
  set DynBuf0_Size  [expr [xget_hw_parameter_value $mhsinst "Size_KB_DynBuf0"] * 1024]
    set DynBuf1_Size  [expr [xget_hw_parameter_value $mhsinst "Size_KB_DynBuf1"] *1024]
    set Errcntr_Size  [xget_hw_parameter_value $mhsinst "Size_B_ErrorCounter"]
    set TxNmtQ_Size   [expr [xget_hw_parameter_value $mhsinst "Size_KB_TxNmtQ"] * 1024]
    set TxGenQ_Size   [expr [xget_hw_parameter_value $mhsinst "Size_KB_TxGenQ"] * 1024]
    set TxSynQ_Size   [expr [xget_hw_parameter_value $mhsinst "Size_KB_TxSynQ"] * 1024]
    set TxVetQ_Size   [expr [xget_hw_parameter_value $mhsinst "Size_KB_TxVetQ"] * 1024]
    set RxVetQ_Size   [expr [xget_hw_parameter_value $mhsinst "Size_KB_RxVetQ"] * 1024]
    set K2UQ_Size   [expr [xget_hw_parameter_value $mhsinst "Size_KB_K2UQ"] * 1024]
    set U2KQ_Size   [expr [xget_hw_parameter_value $mhsinst "Size_KB_U2KQ"] * 1024]
    set Tpdo_Size   [xget_hw_parameter_value $mhsinst "Size_B_Tpdo"]
    set Rpdo_Size   [xget_hw_parameter_value $mhsinst "Size_B_Rpdo"]
    set Qheader_Size 16
    set statusControlSize 2048
  set accumulator [expr $DynBuf0_Size + $DynBuf1_Size + $Errcntr_Size + $TxNmtQ_Size + $TxGenQ_Size + $TxSynQ_Size + $TxVetQ_Size + $RxVetQ_Size + $K2UQ_Size + $U2KQ_Size + $Tpdo_Size + $Rpdo_Size]
    set total [expr $accumulator + 7 * $Qheader_Size + $statusControlSize ]
  return $total
}


proc generate {drv_handle} {
  set mhsinst [xget_hw_parent_handle $drv_handle]
  xdefine_include_file $drv_handle "xparameters.h" "axi_hostinterface" "C_BASEADDR" "C_HIGHADDR" "DEVICE_ID" "C_HOST_BASEADDR" "C_HOST_HIGHADDR" "gBaseDynBuf0" "Size_KB_DynBuf0" "gBaseDynBuf1" "Size_KB_DynBuf1" "gBaseErrCntr" "Size_B_ErrorCounter" \
   "gBaseTxNmtQ" "Size_KB_TxNmtQ" "gBaseTxGenQ" "Size_KB_TxGenQ" "gBaseTxSynQ" "Size_KB_TxSynQ" "gBaseTxVetQ" "Size_KB_TxVetQ" \
  "gBaseRxVetQ" "Size_KB_RxVetQ" "gBaseK2UQ" "Size_KB_K2UQ" "gBaseU2KQ" "Size_KB_U2KQ" "gBaseTpdo" "Size_B_Tpdo" "gBaseRpdo" "Size_B_Rpdo" "gBaseRes"
}