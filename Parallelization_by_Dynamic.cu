﻿
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <fstream>
#include <windows.h>
#include <math.h>
#include <cmath> 

#define TILE_WIDTH 2

using namespace std;

uint8_t sBoxH[256] =
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

uint8_t mixMatrix[16] = { 2,3,1,1,1,2,3,1,1,1,2,3,3,1,1,2 };

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
        word[i] = sBoxH[word[i]];
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

__global__ void mixColumns(uint8_t* text, uint8_t* mixMatrix, int index) {

    __shared__ uint8_t ds_mix[TILE_WIDTH][TILE_WIDTH];
    __shared__ uint8_t ds_state[TILE_WIDTH][TILE_WIDTH];

    int width = 4;
    uint8_t ty = threadIdx.y;
    uint8_t tx = threadIdx.x;
    uint8_t row = blockIdx.y * TILE_WIDTH + threadIdx.y;
    uint8_t col = blockIdx.x * TILE_WIDTH + threadIdx.x;
    uint8_t mixResult[16];
    uint8_t pval = 0;
    uint8_t tempResult = 0;

    for (int ph = 0; ph < ceil(width / (float)TILE_WIDTH); ++ph) {

        if ((row < width) && (ph * TILE_WIDTH + tx) < width)
        {
            ds_mix[ty][tx] = mixMatrix[row * width + ph * TILE_WIDTH + tx];
        }
        else
        {
            ds_mix[ty][tx] = 0;
        }
        if ((ph * TILE_WIDTH + ty) < width && col < width)
        {
            ds_state[ty][tx] = text[((ph * TILE_WIDTH + ty) * width + col) + index * 16];
        }
        else
        {
            ds_state[ty][tx] = 0;
        }

        __syncthreads();

        if (row < width && col < width)
        {
            for (int i = 0; i < TILE_WIDTH; ++i)
            {
                uint8_t currState = ds_state[i][tx];

                switch (ds_mix[ty][i]) {
                case 1:
                    tempResult = ds_state[i][tx];
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
        }
        __syncthreads();

    }

    if ((row < width) && (col < width))
    {
        mixResult[row * width + col] = pval;
    }
    __syncthreads();

    text[(row * width + col) + index * 16] = mixResult[row * width + col];

}

__global__ void addRoundKey(uint8_t* text, uint8_t* key, int index, int round) {

    int thread = threadIdx.x;

    if (thread < 16) {
        text[index * 16 + thread] ^= key[round * 16 + thread];
    }

}

__global__ void subBytes(uint8_t* text, uint8_t* sBox, int index) {

    int thread = threadIdx.x;

    if (thread < 16) {
        text[index * 16 + thread] = sBox[text[index * 16 + thread]];
    }

}

__global__ void shiftRows(uint8_t* text, int index) {

    int thread = threadIdx.x;
    uint8_t out[16];
    if (thread < 16 && thread >= 4) {

        switch (thread) {
        case 4:
            out[4] = text[index * 16 + 5];
            break;
        case 5:
            out[5] = text[index * 16 + 6];
            break;
        case 6:
            out[6] = text[index * 16 + 7];
            break;
        case 7:
            out[7] = text[index * 16 + 4];
            break;
        case 8:
            out[8] = text[index * 16 + 10];
            break;
        case 9:
            out[9] = text[index * 16 + 11];
            break;
        case 10:
            out[10] = text[index * 16 + 8];
            break;
        case 11:
            out[11] = text[index * 16 + 9];
            break;
        case 12:
            out[12] = text[index * 16 + 15];
            break;
        case 13:
            out[13] = text[index * 16 + 12];
            break;
        case 14:
            out[14] = text[index * 16 + 13];
            break;
        case 15:
            out[15] = text[index * 16 + 14];
            break;
        }

        __syncthreads();

        text[index * 16 + thread] = out[thread];
    }
}

__global__ void AESEncryption(uint8_t* text, uint8_t* key, uint8_t* sBox, uint8_t* mMatrix, int blockNumber) {

    int thread = threadIdx.x;
    dim3 dimGrid(1, 1, 1);
    dim3 dimBlock(4, 4, 1);
    if (thread < blockNumber) {

        addRoundKey << <1, 16 >> > (text, key, thread, 0);
        cudaDeviceSynchronize();

        for (int i = 1; i < 14; i++) {
            subBytes << <1, 16 >> > (text, sBox, thread);
            cudaDeviceSynchronize();
            shiftRows << <1, 16 >> > (text, thread);
            cudaDeviceSynchronize();
            mixColumns << <dimGrid, dimBlock >> > (text, mMatrix, thread);
            cudaDeviceSynchronize();
            addRoundKey << <1, 16 >> > (text, key, thread, i);
            cudaDeviceSynchronize();
        }
        subBytes << <1, 16 >> > (text, sBox, thread);
        cudaDeviceSynchronize();
        shiftRows << <1, 16 >> > (text, thread);
        cudaDeviceSynchronize();
        addRoundKey << <1, 16 >> > (text, key, thread, 14);
        cudaDeviceSynchronize();

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
    uint8_t* dev_sBox = 0;
    uint8_t* dev_mixMatrix = 0;

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

    cudaStatus = cudaMalloc((void**)&dev_sBox, 256 * sizeof(uint8_t));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_mixMatrix, 16 * sizeof(uint8_t));
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

    cudaStatus = cudaMemcpy(dev_sBox, sBoxH, 256 * sizeof(uint8_t), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_mixMatrix, mixMatrix, 16 * sizeof(uint8_t), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    float totalThreads = (infileLength + numberOfPadding) / 16;
    int totalBlocks = ceil(totalThreads / 32);
    AESEncryption << <totalBlocks, 32 >> > (dev_text, dev_key, dev_sBox, dev_mixMatrix, blockNumber);

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
    cudaFree(dev_sBox);
    cudaFree(dev_mixMatrix);

    return 0;
}
