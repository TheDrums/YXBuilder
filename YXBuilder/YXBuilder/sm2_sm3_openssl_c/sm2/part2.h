#ifndef PART2_H
#define PART2_H

#include "sm2.h"

void test_part2(char **sm2_param, int type, int point_bit_length);


typedef struct
{
    BYTE *message;
    int message_byte_length;
    BYTE *ID;
    int ENTL;
    BYTE k[MAX_POINT_BYTE_LENGTH];   //签名中产生随机数
    BYTE private_key[MAX_POINT_BYTE_LENGTH];
    struct
    {
        BYTE x[MAX_POINT_BYTE_LENGTH];
        BYTE y[MAX_POINT_BYTE_LENGTH];
    }public_key;
    BYTE Z[HASH_BYTE_LENGTH];
    BYTE r[MAX_POINT_BYTE_LENGTH];
    BYTE s[MAX_POINT_BYTE_LENGTH];
    BYTE R[MAX_POINT_BYTE_LENGTH];
} sm2_sign_st;

BYTE* sm2_sign(ec_param *ecp, sm2_sign_st *sign);

void sm2_verify(ec_param *ecp, sm2_sign_st *sign);

#endif;
