//========================================================================
// riscv-mulh.S
//========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------



        // Positive operands

        TEST_RR_OP( mulh, 123456, 987654,  28 )
        TEST_RR_OP( mulh, 876543, 234567,  47 )

        // Negative operands

        TEST_RR_OP( mulh,  -456789,  -654321, 69)
        TEST_RR_OP( mulh, -123456,  -789012,  22 )

        // Mixed tests

        TEST_RR_OP( mulh, 123456, -987654,-29)
        TEST_RR_OP( mulh, 876543, -234567, -48 )
        TEST_RR_OP( mulh, 567890, -345678, -46 )

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( mulh, 567890, 345678, 45 )
        TEST_RR_SRC1_EQ_DEST( mulh, -234567, -876543, 47)
        TEST_RR_SRC0_EQ_SRC1( mulh,1234567, 354 )
        TEST_RR_SRCS_EQ_DEST( mulh, -7654321, 13641 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP(0, mulh,123456, 987654, 28)
        TEST_RR_DEST_BYP(1, mulh,876543, 234567, 47)
        TEST_RR_DEST_BYP(2, mulh,-456789, -654321, 69)
        TEST_RR_DEST_BYP(3, mulh,-123456, -789012, 22)
        TEST_RR_DEST_BYP(4, mulh,123456, -987654, -29)

        TEST_RR_SRC01_BYP(0,0, mulh,-7654321, -7654321, 13641)
        TEST_RR_SRC01_BYP(0,1, mulh,123456, -987654, -29)
        TEST_RR_SRC01_BYP(0,2, mulh,567890, 345678, 45)
        TEST_RR_SRC01_BYP(0,3, mulh,-123456, -789012, 22)
        TEST_RR_SRC01_BYP(0,4, mulh,123456, 987654, 28)

        TEST_RR_SRC10_BYP(0,0, mulh,123456, 987654, 28)
        TEST_RR_SRC10_BYP(0,1, mulh,123456, 987654, 28)
        TEST_RR_SRC10_BYP(0,2, mulh,-7654321, -7654321, 13641)
        TEST_RR_SRC10_BYP(0,3, mulh,-123456, -789012, 22)
        TEST_RR_SRC10_BYP(0,4, mulh,876543, -234567, -48)

        TEST_RR_SRC10_BYP(1,0, mulh,-7654321, -7654321, 13641)
        TEST_RR_SRC10_BYP(1,1, mulh,1234567, 1234567, 354)
        TEST_RR_SRC10_BYP(2,0, mulh,123456, 987654, 28)   

        TEST_RISCV_END

