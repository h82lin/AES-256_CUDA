
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <fstream>
#include <windows.h>

using namespace std;

uint8_t sBoxO[256] =
{
    0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76,
    0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0,
    0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15,
    0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75,
    0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84,
    0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF,
    0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8,
    0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2,
    0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73,
    0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB,
    0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79,
    0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08,
    0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A,
    0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E,
    0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF,
    0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16
};

uint8_t rcon[256] = {
    0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a,
    0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39,
    0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a,
    0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8,
    0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef,
    0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc,
    0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b,
    0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3,
    0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94,
    0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20,
    0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35,
    0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f,
    0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04,
    0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63,
    0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd,
    0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d
};

void rotWord(uint8_t* word);
void subWord(uint8_t* word);
void rCon(uint8_t* word, int iteration);
void keyExpansion(uint8_t* inputKey, uint8_t* expandedKeys);

double PCFreq = 0.0;
__int64 CounterStart = 0;

void StartCounter()
{
    LARGE_INTEGER li;
    if (!QueryPerformanceFrequency(&li))
        cout << "QueryPerformanceFrequency failed!\n";

    PCFreq = double(li.QuadPart) / 1000.0;

    QueryPerformanceCounter(&li);
    CounterStart = li.QuadPart;
}

double GetCounter()
{
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    return double(li.QuadPart - CounterStart) / PCFreq;
}

void rotWord(uint8_t* word) {
    uint8_t temp = word[0];
    for (int i = 0; i < 3; i++) {
        word[i] = word[i + 1];
    }
    word[3] = temp;
}

void subWord(uint8_t* word) {
    for (int i = 0; i < 4; i++) {
        word[i] = sBoxO[word[i]];
    }
}

void rCon(uint8_t* word, int iteration) {
    word[0] ^= rcon[iteration];
}

void keyExpansion(uint8_t* inputKey, uint8_t* expandedKeys) {
    for (int i = 0; i < 32; i++) {
        expandedKeys[i] = inputKey[i];
    }

    int bytesGenerated = 32;
    int rconIteration = 1;
    uint8_t tmpCore[4];

    while (bytesGenerated < 240) {

        for (int i = 0; i < 4; i++) {
            tmpCore[i] = expandedKeys[i + bytesGenerated - 4];
        }

        if (bytesGenerated % 32 == 0) {
            rotWord(tmpCore);
            subWord(tmpCore);
            rCon(tmpCore, rconIteration);
            rconIteration++;
        }
        else if (bytesGenerated % 16 == 0) {
            subWord(tmpCore);
        }

        for (int i = 0; i < 4; i++) {
            expandedKeys[bytesGenerated] = expandedKeys[bytesGenerated - 16] ^ tmpCore[i];
            bytesGenerated++;
        }

    }
}

__device__ void load(uint8_t* sBox, uint8_t* mixMatrix) {

    sBox[0] = 0x63; sBox[1] = 0x7c; sBox[2] = 0x77; sBox[3] = 0x7b; sBox[4] = 0xf2; sBox[5] = 0x6b; sBox[6] = 0x6f; sBox[7] = 0xc5; sBox[8] = 0x30; sBox[9] = 0x1; sBox[10] = 0x67; sBox[11] = 0x2b; sBox[12] = 0xfe; sBox[13] = 0xd7; sBox[14] = 0xab; sBox[15] = 0x76;
    sBox[16] = 0xca; sBox[17] = 0x82; sBox[18] = 0xc9; sBox[19] = 0x7d; sBox[20] = 0xfa; sBox[21] = 0x59; sBox[22] = 0x47; sBox[23] = 0xf0; sBox[24] = 0xad; sBox[25] = 0xd4; sBox[26] = 0xa2; sBox[27] = 0xaf; sBox[28] = 0x9c; sBox[29] = 0xa4; sBox[30] = 0x72; sBox[31] = 0xc0;
    sBox[32] = 0xb7; sBox[33] = 0xfd; sBox[34] = 0x93; sBox[35] = 0x26; sBox[36] = 0x36; sBox[37] = 0x3f; sBox[38] = 0xf7; sBox[39] = 0xcc; sBox[40] = 0x34; sBox[41] = 0xa5; sBox[42] = 0xe5; sBox[43] = 0xf1; sBox[44] = 0x71; sBox[45] = 0xd8; sBox[46] = 0x31; sBox[47] = 0x15;
    sBox[48] = 0x4; sBox[49] = 0xc7; sBox[50] = 0x23; sBox[51] = 0xc3; sBox[52] = 0x18; sBox[53] = 0x96; sBox[54] = 0x5; sBox[55] = 0x9a; sBox[56] = 0x7; sBox[57] = 0x12; sBox[58] = 0x80; sBox[59] = 0xe2; sBox[60] = 0xeb; sBox[61] = 0x27; sBox[62] = 0xb2; sBox[63] = 0x75;
    sBox[64] = 0x9; sBox[65] = 0x83; sBox[66] = 0x2c; sBox[67] = 0x1a; sBox[68] = 0x1b; sBox[69] = 0x6e; sBox[70] = 0x5a; sBox[71] = 0xa0; sBox[72] = 0x52; sBox[73] = 0x3b; sBox[74] = 0xd6; sBox[75] = 0xb3; sBox[76] = 0x29; sBox[77] = 0xe3; sBox[78] = 0x2f; sBox[79] = 0x84;
    sBox[80] = 0x53; sBox[81] = 0xd1; sBox[82] = 0x0; sBox[83] = 0xed; sBox[84] = 0x20; sBox[85] = 0xfc; sBox[86] = 0xb1; sBox[87] = 0x5b; sBox[88] = 0x6a; sBox[89] = 0xcb; sBox[90] = 0xbe; sBox[91] = 0x39; sBox[92] = 0x4a; sBox[93] = 0x4c; sBox[94] = 0x58; sBox[95] = 0xcf;
    sBox[96] = 0xd0; sBox[97] = 0xef; sBox[98] = 0xaa; sBox[99] = 0xfb; sBox[100] = 0x43; sBox[101] = 0x4d; sBox[102] = 0x33; sBox[103] = 0x85; sBox[104] = 0x45; sBox[105] = 0xf9; sBox[106] = 0x2; sBox[107] = 0x7f; sBox[108] = 0x50; sBox[109] = 0x3c; sBox[110] = 0x9f; sBox[111] = 0xa8;
    sBox[112] = 0x51; sBox[113] = 0xa3; sBox[114] = 0x40; sBox[115] = 0x8f; sBox[116] = 0x92; sBox[117] = 0x9d; sBox[118] = 0x38; sBox[119] = 0xf5; sBox[120] = 0xbc; sBox[121] = 0xb6; sBox[122] = 0xda; sBox[123] = 0x21; sBox[124] = 0x10; sBox[125] = 0xff; sBox[126] = 0xf3; sBox[127] = 0xd2;
    sBox[128] = 0xcd; sBox[129] = 0xc; sBox[130] = 0x13; sBox[131] = 0xec; sBox[132] = 0x5f; sBox[133] = 0x97; sBox[134] = 0x44; sBox[135] = 0x17; sBox[136] = 0xc4; sBox[137] = 0xa7; sBox[138] = 0x7e; sBox[139] = 0x3d; sBox[140] = 0x64; sBox[141] = 0x5d; sBox[142] = 0x19; sBox[143] = 0x73;
    sBox[144] = 0x60; sBox[145] = 0x81; sBox[146] = 0x4f; sBox[147] = 0xdc; sBox[148] = 0x22; sBox[149] = 0x2a; sBox[150] = 0x90; sBox[151] = 0x88; sBox[152] = 0x46; sBox[153] = 0xee; sBox[154] = 0xb8; sBox[155] = 0x14; sBox[156] = 0xde; sBox[157] = 0x5e; sBox[158] = 0xb; sBox[159] = 0xdb;
    sBox[160] = 0xe0; sBox[161] = 0x32; sBox[162] = 0x3a; sBox[163] = 0xa; sBox[164] = 0x49; sBox[165] = 0x6; sBox[166] = 0x24; sBox[167] = 0x5c; sBox[168] = 0xc2; sBox[169] = 0xd3; sBox[170] = 0xac; sBox[171] = 0x62; sBox[172] = 0x91; sBox[173] = 0x95; sBox[174] = 0xe4; sBox[175] = 0x79;
    sBox[176] = 0xe7; sBox[177] = 0xc8; sBox[178] = 0x37; sBox[179] = 0x6d; sBox[180] = 0x8d; sBox[181] = 0xd5; sBox[182] = 0x4e; sBox[183] = 0xa9; sBox[184] = 0x6c; sBox[185] = 0x56; sBox[186] = 0xf4; sBox[187] = 0xea; sBox[188] = 0x65; sBox[189] = 0x7a; sBox[190] = 0xae; sBox[191] = 0x8;
    sBox[192] = 0xba; sBox[193] = 0x78; sBox[194] = 0x25; sBox[195] = 0x2e; sBox[196] = 0x1c; sBox[197] = 0xa6; sBox[198] = 0xb4; sBox[199] = 0xc6; sBox[200] = 0xe8; sBox[201] = 0xdd; sBox[202] = 0x74; sBox[203] = 0x1f; sBox[204] = 0x4b; sBox[205] = 0xbd; sBox[206] = 0x8b; sBox[207] = 0x8a;
    sBox[208] = 0x70; sBox[209] = 0x3e; sBox[210] = 0xb5; sBox[211] = 0x66; sBox[212] = 0x48; sBox[213] = 0x3; sBox[214] = 0xf6; sBox[215] = 0xe; sBox[216] = 0x61; sBox[217] = 0x35; sBox[218] = 0x57; sBox[219] = 0xb9; sBox[220] = 0x86; sBox[221] = 0xc1; sBox[222] = 0x1d; sBox[223] = 0x9e;
    sBox[224] = 0xe1; sBox[225] = 0xf8; sBox[226] = 0x98; sBox[227] = 0x11; sBox[228] = 0x69; sBox[229] = 0xd9; sBox[230] = 0x8e; sBox[231] = 0x94; sBox[232] = 0x9b; sBox[233] = 0x1e; sBox[234] = 0x87; sBox[235] = 0xe9; sBox[236] = 0xce; sBox[237] = 0x55; sBox[238] = 0x28; sBox[239] = 0xdf;
    sBox[240] = 0x8c; sBox[241] = 0xa1; sBox[242] = 0x89; sBox[243] = 0xd; sBox[244] = 0xbf; sBox[245] = 0xe6; sBox[246] = 0x42; sBox[247] = 0x68; sBox[248] = 0x41; sBox[249] = 0x99; sBox[250] = 0x2d; sBox[251] = 0xf; sBox[252] = 0xb0; sBox[253] = 0x54; sBox[254] = 0xbb; sBox[255] = 0x16;


    mixMatrix[0] = 2; mixMatrix[1] = 3; mixMatrix[2] = 1; mixMatrix[3] = 1; mixMatrix[4] = 1; mixMatrix[5] = 2; mixMatrix[6] = 3; mixMatrix[7] = 1; mixMatrix[8] = 1;
    mixMatrix[9] = 1; mixMatrix[10] = 2; mixMatrix[11] = 3; mixMatrix[12] = 3; mixMatrix[13] = 1; mixMatrix[14] = 1; mixMatrix[15] = 2;

}

__device__ void mixColumns(uint8_t* state, uint8_t* mixMatrix) {

    uint8_t tempResult = 0;
    uint8_t pval = 0;
    uint8_t currState;
    uint8_t result[16];

    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 4; k++) {
                currState = state[k * 4 + j];
                switch (mixMatrix[i * 4 + k]) {
                case 1:
                    tempResult = currState;
                    break;
                case 2:
                    if (currState >= 128) {
                        tempResult = currState << 1;
                        tempResult ^= 27;
                    }
                    else {
                        tempResult = currState << 1;
                    }
                    break;
                case 3:
                    if (currState >= 128) {
                        tempResult = currState << 1;
                        tempResult ^= 27;
                    }
                    else {
                        tempResult = currState << 1;
                    }
                    tempResult ^= currState;
                    break;
                }
                pval ^= tempResult;
            }
            result[i * 4 + j] = pval;
        }

    }

    for (int i = 0; i < 16; i++) {
        state[i] = result[i];
    }
}

__device__ void addRoundKey(uint8_t* state, uint8_t* key, int round) {

    for (int i = 0; i < 16; i++) {
        state[i] ^= key[round * 16 + i];
    }

}

__device__ void subBytes(uint8_t* state, uint8_t* sBox) {

    for (int i = 0; i < 16; i++) {
        state[i] = sBox[state[i]];
    }

}

__device__ void shiftRows(uint8_t* state) {

    uint8_t out[16];

    out[4] = state[5];
    out[5] = state[6];
    out[6] = state[7];
    out[7] = state[4];

    out[8] = state[10];
    out[9] = state[11];
    out[10] = state[8];
    out[11] = state[9];

    out[12] = state[15];
    out[13] = state[12];
    out[14] = state[13];
    out[15] = state[14];

    for (int i = 4; i < 16; i++) {
        state[i] = out[i];
    }
}

__global__ void AESEncryption(uint8_t* text, uint8_t* key, int blockNumber) {

    int thread = blockDim.x * blockIdx.x + threadIdx.x;

    __shared__ uint8_t sBox[256];
    __shared__ uint8_t mixMatrix[16];

    if (thread < blockNumber) {

        if (thread == 0) {
            load(sBox, mixMatrix);
        }
        __syncthreads();

        uint8_t currBlock[16];
        for (int i = 0; i < 16; i++) {
            currBlock[i] = text[thread * 16 + i];
        }
        addRoundKey(currBlock, key, 0);

        for (int i = 1; i < 14; i++) {
            subBytes(currBlock, sBox);
            shiftRows(currBlock);
            mixColumns(currBlock, mixMatrix);
            addRoundKey(currBlock, key, i);
        }
        subBytes(currBlock, sBox);
        shiftRows(currBlock);
        addRoundKey(currBlock, key, 14);


        for (int i = 0; i < 16; i++) {
            text[thread * 16 + i] = currBlock[i];
        }
    }
}


int main()
{
    ifstream ifs;
    ifs.open("plaintext.txt", std::ifstream::binary);
    if (!ifs) {
        cerr << "Cannot open the input file" << endl;
        exit(1);
    }
    ifs.seekg(0, ios::end);
    int infileLength = ifs.tellg();
    ifs.seekg(0, ios::beg);
    int blockNumber = infileLength / 16;
    int numberOfPadding = infileLength % 16;
    char* tempText = new char[(infileLength + numberOfPadding) * sizeof(char)];
    char  tempKey[32];
    uint8_t* text = new uint8_t[(infileLength + numberOfPadding) * sizeof(uint8_t)];
    uint8_t key[32];
    int textLen = infileLength + numberOfPadding;

    ifstream key_fp;
    key_fp.open("key.txt");
    if (!key_fp) {
        cerr << "Cannot open the key file" << endl;
        exit(1);
    }
    key_fp.seekg(0, ios::end);
    int keyfileLength = key_fp.tellg();
    key_fp.seekg(0, ios::beg);

    if (keyfileLength != 32) {
        printf("%s", "The key in key.txt needs to be 32 characters");
        return 0;
    }

    key_fp.read(tempKey, 32);

    ifs.read(tempText, infileLength);

    for (int i = 0; i < 32; i++) {
        key[i] = uint8_t(tempKey[i]);
    }

    for (int i = 0; i < infileLength; i++) {
        text[i] = uint8_t(tempText[i]);
    }

    for (int i = 0; i < numberOfPadding; i++) {
        text[infileLength - 1 + i] = uint8_t(numberOfPadding);
    }

    uint8_t expandedKey[240];
    keyExpansion(key, expandedKey);

    StartCounter();

    uint8_t* dev_text = 0;
    uint8_t* dev_key = 0;
    int textSize = (infileLength + numberOfPadding) * sizeof(uint8_t);
    int keySize = 240 * sizeof(uint8_t);
    cudaError_t cudaStatus;

    cudaStatus = cudaMalloc((void**)&dev_text, textSize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_key, keySize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_text, text, textSize, cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_key, expandedKey, keySize, cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    float totalThreads = (infileLength + numberOfPadding) / 16;
    int totalBlocks = ceil(totalThreads / 32);

    AESEncryption << <totalBlocks, 32 >> > (dev_text, dev_key, blockNumber);

    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching!\n", cudaStatus);
        goto Error;
    }

    cudaStatus = cudaMemcpy(text, dev_text, textSize, cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cout << "Execution Time: " << GetCounter() << " ms" << "\n";

    FILE* out_fp;
    out_fp = fopen("cipher.txt", "wb+");

    for (int j = 0; j < textLen; j++) {
        fprintf(out_fp, "%x ", text[j]);
    }

Error:
    cudaFree(dev_text);
    cudaFree(dev_key);

    return 0;
}
