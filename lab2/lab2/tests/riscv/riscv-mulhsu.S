//========================================================================
// riscv-mulhsu.S
//========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------



        TEST_RR_OP(mulhsu,1234567, 1234567, 354)
        TEST_RR_OP(mulhsu,123456, 789012, 22)
        TEST_RR_OP(mulhsu,567890, 345678, 45)
        TEST_RR_OP(mulhsu,123456, 987654, 28)
        TEST_RR_OP(mulhsu,876543, 234567, 47)
        TEST_RR_OP(mulhsu,-987654, 123456,-29)
        TEST_RR_OP(mulhsu,-234567, 876543, -48)
        TEST_RR_OP(mulhsu,-345678, 567890, -46)

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( mulhsu, 567890, 345678, 45 )
        TEST_RR_SRC1_EQ_DEST( mulhsu, 234567, 876543, 47)
        TEST_RR_SRC0_EQ_SRC1( mulhsu, 1234567, 354 )
        TEST_RR_SRCS_EQ_DEST( mulhsu, 7654321, 13641 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP(0, mulhsu,123456, 987654, 28)
        TEST_RR_DEST_BYP(1, mulhsu,876543, 234567, 47)
        TEST_RR_DEST_BYP(2, mulhsu,456789, 654321, 69)
        TEST_RR_DEST_BYP(3, mulhsu,123456, 789012, 22)
        TEST_RR_DEST_BYP(4, mulhsu,-123456, 987654, -29)

        TEST_RR_SRC01_BYP(0,0, mulhsu,7654321, 7654321, 13641)
        TEST_RR_SRC01_BYP(0,1, mulhsu,123456, 987654, 28)
        TEST_RR_SRC01_BYP(0,2, mulhsu,-567890, 345678,-46)
        TEST_RR_SRC01_BYP(0,3, mulhsu,123456, 789012, 22)
        TEST_RR_SRC01_BYP(0,4, mulhsu,123456, 987654, 28)

        TEST_RR_SRC10_BYP(0,0, mulhsu,123456, 987654, 28)
        TEST_RR_SRC10_BYP(0,1, mulhsu,123456, 987654, 28)
        TEST_RR_SRC10_BYP(0,2, mulhsu,7654321, 7654321, 13641)
        TEST_RR_SRC10_BYP(0,3, mulhsu,123456, 789012, 22)
        TEST_RR_SRC10_BYP(0,4, mulhsu,-876543, 234567, -48)

        TEST_RR_SRC10_BYP(1,0, mulhsu,7654321, 7654321, 13641)
        TEST_RR_SRC10_BYP(1,1, mulhsu,1234567, 1234567, 354)
        TEST_RR_SRC10_BYP(2,0, mulhsu,-123456, 987654, -29)   

        TEST_RISCV_END

