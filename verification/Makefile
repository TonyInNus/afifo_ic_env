#-------------------------------------------------------------------------------------------------------
all: \
		vcs \
		verdi

#-------------------------------------------------------------------------------------------------------
# VCS
vcs   :
	vcs  \
		-f hdl.files \
        -timescale=1ns/1ns \
        -full64  -R  +vc  +v2k  -sverilog  -debug_access+all  \
        |tee vcs.log  
#-------------------------------------------------------------------------------------------------------
# questasim

questasim: com sim
com:
	vlib work 
	vmap work work
	vlog -64 -sv +acc \
	-f hdl.files \
	-l com_questa.log

sim:
	vsim \
		-64 -batch -pli $(VERDI_HOME)/share/PLI/MODELSIM/linux64/novas_fli.so \
		-t 1ns \
  		work.tb \
		-do "run -all"

#-------------------------------------------------------------------------------------------------------
# verdi

verdi  :
	verdi -sv -f hdl.files -ssf wave.fsdb &

#-------------------------------------------------------------------------------------------------------
clean  :
	 rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd
	 rm -rf INCA_libs irun*
	 rm -rf modelsim.ini transcript work
#-------------------------------------------------------------------------------------------------------
