transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Tomahawk/Source/Repos/lab_ri {C:/Users/Tomahawk/Source/Repos/lab_ri/csce611_lab_ri.sv}
vlog -sv -work work +incdir+C:/Users/Tomahawk/Source/Repos/lab_ri {C:/Users/Tomahawk/Source/Repos/lab_ri/hexdriver.sv}

