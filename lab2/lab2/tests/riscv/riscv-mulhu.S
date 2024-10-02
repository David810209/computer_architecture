//========================================================================
// riscv-mulhu.S
//========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------



        TEST_RR_OP(mulhu,1234567, 1234567, 354)
        TEST_RR_OP(mulhu,123456, 789012, 22)
        TEST_RR_OP(mulhu,567890, 345678, 45)
        TEST_RR_OP(mulhu,123456, 987654, 28)
        TEST_RR_OP(mulhu,876543, 234567, 47)
        TEST_RR_OP(mulhu,876543, 234567, 47)
        TEST_RR_OP(mulhu,234567, 876543, 47)
        TEST_RR_OP(mulhu,123456, 987654, 28)

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( mulhu, 567890, 345678, 45 )
        TEST_RR_SRC1_EQ_DEST( mulhu, 234567, 876543, 47)
        TEST_RR_SRC0_EQ_SRC1( mulhu,1234567, 354 )
        TEST_RR_SRCS_EQ_DEST( mulhu, 7654321, 13641 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP(0, mulhu,123456, 987654, 28)
        TEST_RR_DEST_BYP(1, mulhu,876543, 234567, 47)
        TEST_RR_DEST_BYP(2, mulhu,456789, 654321, 69)
        TEST_RR_DEST_BYP(3, mulhu,123456, 789012, 22)
        TEST_RR_DEST_BYP(4, mulhu,123456, 987654, 28)

        TEST_RR_SRC01_BYP(0,0, mulhu,7654321, 7654321, 13641)
        TEST_RR_SRC01_BYP(0,1, mulhu,123456, 987654, 28)
        TEST_RR_SRC01_BYP(0,2, mulhu,567890, 345678, 45)
        TEST_RR_SRC01_BYP(0,3, mulhu,123456, 789012, 22)
        TEST_RR_SRC01_BYP(0,4, mulhu,123456, 987654, 28)

        TEST_RR_SRC10_BYP(0,0, mulhu,123456, 987654, 28)
        TEST_RR_SRC10_BYP(0,1, mulhu,123456, 987654, 28)
        TEST_RR_SRC10_BYP(0,2, mulhu,7654321, 7654321, 13641)
        TEST_RR_SRC10_BYP(0,3, mulhu,123456, 789012, 22)
        TEST_RR_SRC10_BYP(0,4, mulhu,876543, 234567, 47)

        TEST_RR_SRC10_BYP(1,0, mulhu,7654321, 7654321, 13641)
        TEST_RR_SRC10_BYP(1,1, mulhu,1234567, 1234567, 354)
        TEST_RR_SRC10_BYP(2,0, mulhu,123456, 987654, 28)   

        TEST_RISCV_END

