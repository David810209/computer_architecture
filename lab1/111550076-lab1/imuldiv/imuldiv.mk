#=========================================================================
# imuldiv Subpackage
#=========================================================================

imuldiv_deps = vc

imuldiv_srcs = \
  imuldiv-DivReqMsg.v \
  imuldiv-MulDivReqMsg.v \
  imuldiv-IntMulDivSingleCycle.v \
  imuldiv-IntMulIterative.v \
  imuldiv-IntDivIterative.v \
  imuldiv-IntMulDivIterative.v \
  imuldiv-ThreeMulDivReqMsg.v \
  imuldiv-IntMulVariable.v \
  imuldiv-IntMulDivThreeInput.v \
 # imuldiv-IntMulPipelined.v 
imuldiv_test_srcs = \
  imuldiv-DivReqMsg.t.v \
  imuldiv-MulDivReqMsg.t.v \
  imuldiv-IntMulDivSingleCycle.t.v \
  imuldiv-IntMulIterative.t.v \
  imuldiv-IntDivIterative.t.v \
  imuldiv-IntMulDivIterative.t.v \
  imuldiv-ThreeMulDivReqMsg.t.v \
  imuldiv-IntMulVariable.t.v \
  imuldiv-IntMulDivThreeInput.t.v \
  # imuldiv-IntMulPipelined.t.v 

  
imuldiv_prog_srcs = \
  imuldiv-singcyc-sim.v \
  imuldiv-iterative-sim.v \

