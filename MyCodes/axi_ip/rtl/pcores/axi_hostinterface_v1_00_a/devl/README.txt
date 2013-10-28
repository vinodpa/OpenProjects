TABLE OF CONTENTS
  1) Peripheral Summary
  2) Description of Generated Files
  3) Location to documentation of dependent libraries
================================================================================
*                             1) Peripheral Summary                            *
================================================================================
Peripheral Summary:

  XPS project / EDK repository               : D:\MY_EXP\Coding\myworks\OpenProjects\MyCodes\axi_ip\ReferenceDesign\sp605
  logical library name                       : axi_hostinterface_v1_00_a
  top name                                   : axi_hostinterface
  version                                    : 1.00.a
  type                                       : AXI4LITE slave
  features                                   : slave attachment

Address Block for User Logic and IPIF Predefined Services

  user logic slave space                     : C_BASEADDR
                                             : C_BASEADDR


================================================================================
*                          2) Description of Generated Files                   *
================================================================================
- HDL source file(s)

  hdl/vhdl/axi_hostinterface.vhd

    This is the template file for your peripheral's top design entity. It
    configures and instantiates the corresponding design units in the way you
    indicated in the wizard GUI and hooks it up to the stub user logic where
    the actual functionalites should get implemented. You are not expected to
    modify this template file except certain marked places for adding user
    specific generics and ports.

  vhdl/user_logic.vhd

    This is the template file for the stub user logic design entity, either in
    VHDL or Verilog, where the actual functionalities should get implemented.
    Some sample code snippet may be provided for demonstration purpose.

- XPS interface file(s)

  data/axi_hostinterface_v2_1_0.mpd

    This Microprocessor Peripheral Description file contains information of the
    interface of your peripheral, so that other EDK tools can recognize your
    peripheral.

  data/axi_hostinterface_v2_1_0.pao

    This Peripheral Analysis Order file defines the analysis order of all the HDL
    source files that are used to compile your peripheral.

- Other misc file(s)

  devl/ipwiz.opt

    This is the option setting file for the wizard batch mode, which should
    generate the same result as the wizard GUI mode.

  devl/README.txt

    This README file for your peripheral.

  devl/ipwiz.log

    This is the log file by operating on this wizard.


================================================================================
*          3) Location to documentation of dependent libraries                 *
*                                                                              *
*   In general, the documentation is located under:                            *
*   $XILINX_EDK/hw/XilinxProcessorIPLib/pcores/$libName/doc                    *
*                                                                              *
================================================================================
proc_common_v3_00_a
	No documentation for this library

axi_lite_ipif_v1_01_a
	D:\MY_EXP\Coding\myworks\OpenProjects\MyCodes\axi_ip\ReferenceDesign\sp605\C:\Xilinx\14.6\ISE_DS\EDK\hw\XilinxProcessorIPLib\pcores\axi_lite_ipif_v1_01_a\doc\axi_lite_ipif_ds765.pdf

