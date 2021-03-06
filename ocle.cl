

#define Nb 4
#define BlockSize 16

#if defined(AES128)
	#define Nk 4
	#define Nr 10
	#define KeyLen 16
	#define KeyExpSize 176
#elif defined(AES192)
	#define Nk 6
	#define Nr 12
	#define KeyLen 24
	#define KeyExpSize 208
#elif defined(AES256)
	#define Nk 8
	#define Nr 14
	#define KeyLen 32
	#define KeyExpSize 240
#endif

typedef unsigned char uint8_t;
typedef unsigned int uint32_t;

typedef uint8_t state_t[4][4];

/**********************************************************************************/

__constant uint8_t sbox[256] =
	{
		/*0*/ /*1*/ /*2*/ /*3*/ /*4*/ /*5*/ /*6*/ /*7*/ /*8*/ /*9*/ /*A*/ /*B*/ /*C*/ /*D*/ /*E*/ /*F*/
/*0*/	0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
/*1*/	0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
/*2*/	0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
/*3*/	0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
/*4*/	0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
/*5*/	0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
/*6*/	0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
/*7*/	0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
/*8*/	0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
/*9*/	0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
/*A*/	0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
/*B*/	0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
/*C*/	0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
/*D*/	0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
/*E*/	0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
/*F*/	0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
	};

__constant uint8_t rsbox[256] =
	{
		/*0*/ /*1*/ /*2*/ /*3*/ /*4*/ /*5*/ /*6*/ /*7*/ /*8*/ /*9*/ /*A*/ /*B*/ /*C*/ /*D*/ /*E*/ /*F*/
/*0*/	0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
/*1*/	0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
/*2*/	0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
/*3*/	0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
/*4*/	0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
/*5*/	0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
/*6*/	0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
/*7*/	0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
/*8*/	0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
/*9*/	0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
/*A*/	0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
/*B*/	0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
/*C*/	0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
/*D*/	0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
/*E*/	0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
/*F*/	0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
	};

__constant uint8_t rcon[11] =
	{
		/*0*/ /*1*/ /*2*/ /*3*/ /*4*/ /*5*/ /*6*/ /*7*/ /*8*/ /*9*/ /*A*/
		0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36
	};

/**********************************************************************************/

// functions

void KeyExpansion(uint8_t *round_key, uint8_t *key) {
	uint8_t temp[4];

	for(uint8_t i=0; i<Nk; ++i) {
		round_key[(i*4) + 0] = key[(i*4) + 0];
		round_key[(i*4) + 1] = key[(i*4) + 1];
		round_key[(i*4) + 2] = key[(i*4) + 2];
		round_key[(i*4) + 3] = key[(i*4) + 3];
	}

	for(uint8_t i=Nk; i<Nb*(Nr+1); ++i) {
		{
			uint8_t j = (i - 1) * 4;
			temp[0] = round_key[j + 0];
			temp[1] = round_key[j + 1];
			temp[2] = round_key[j + 2];
			temp[3] = round_key[j + 3];
		}

		if(i % Nk == 0) {
			const uint8_t tmp = temp[0];
			temp[0] = temp[1];
			temp[1] = temp[2];
			temp[2] = temp[3];
			temp[3] = tmp;

			for(uint8_t j=0; j<4; ++j)
				temp[j] = sbox[temp[j]];

			temp[0] = temp[0] ^ rcon[i/Nk];
		}

#ifdef AES256
		if(i % Nk == 4)
			for(uint8_t j=0; j<4; ++j)
				temp[j] = sbox[temp[j]];
#endif

		{
			uint8_t j = i * 4;
			uint8_t k = (i - Nk) * 4;
			for(uint8_t l=0; l<4; ++l)
				round_key[j+l] = round_key[k+l] ^ temp[l];
		}
	}
}

void AddRoundKey(uint8_t round, state_t *state, const uint8_t *round_key) {
	for(uint8_t i=0; i<4; ++i)
		for(uint8_t j=0; j<4; j++)
			(*state)[i][j] ^= round_key[(round * Nb * 4) + (i * Nb) + j];
}

void SubBytes(state_t *state) {
	for(uint8_t i=0; i<4; ++i)
		for(uint8_t j=0; j<4; ++j)
			(*state)[j][i] = sbox[(*state)[j][i]];
}

void ShiftRows(state_t *state) {
	uint8_t tmp;

	tmp            = (*state)[0][1];
	(*state)[0][1] = (*state)[1][1];
	(*state)[1][1] = (*state)[2][1];
	(*state)[2][1] = (*state)[3][1];
	(*state)[3][1] = tmp;

	tmp            = (*state)[0][2];
	(*state)[0][2] = (*state)[2][2];
	(*state)[2][2] = tmp;

	tmp            = (*state)[1][2];
	(*state)[1][2] = (*state)[3][2];
	(*state)[3][2] = tmp;

	tmp            = (*state)[0][3];
	(*state)[0][3] = (*state)[3][3];
	(*state)[3][3] = (*state)[2][3];
	(*state)[2][3] = (*state)[1][3];
	(*state)[1][3] = tmp;
}

uint8_t xtime2(uint8_t x) {
	return ((x<<1) ^ (((x>>7) & 1) * 0x1b));
}

void MixColumns(state_t *state){
	for(uint8_t i=0; i<4; ++i) {
		uint8_t t = (*state)[i][0];
		uint8_t tmp = (*state)[i][0] ^ (*state)[i][1] ^ (*state)[i][2] ^ (*state)[i][3];
		(*state)[i][0] ^= xtime2((*state)[i][0] ^ (*state)[i][1]) ^ tmp;
		(*state)[i][1] ^= xtime2((*state)[i][1] ^ (*state)[i][2]) ^ tmp;
		(*state)[i][2] ^= xtime2((*state)[i][2] ^ (*state)[i][3]) ^ tmp;
		(*state)[i][3] ^= xtime2((*state)[i][3] ^ t) ^ tmp;
	}
}

void Cipher(state_t *state, const uint8_t *round_key) {
	AddRoundKey(0, state, round_key);

	for(uint8_t round=1;; ++round) {
		SubBytes(state);
		ShiftRows(state);

		if(round == Nr)
			break;

		MixColumns(state);
		AddRoundKey(round, state, round_key);
	}
	AddRoundKey(Nr, state, round_key);
}

void InvShiftRows(state_t *state) {
	uint8_t tmp;

	tmp = (*state)[3][1];
	(*state)[3][1] = (*state)[2][1];
	(*state)[2][1] = (*state)[1][1];
	(*state)[1][1] = (*state)[0][1];
	(*state)[0][1] = tmp;

	tmp = (*state)[0][2];
	(*state)[0][2] = (*state)[2][2];
	(*state)[2][2] = tmp;

	tmp = (*state)[1][2];
	(*state)[1][2] = (*state)[3][2];
	(*state)[3][2] = tmp;

	tmp = (*state)[0][3];
	(*state)[0][3] = (*state)[1][3];
	(*state)[1][3] = (*state)[2][3];
	(*state)[2][3] = (*state)[3][3];
	(*state)[3][3] = tmp;
}

void InvSubBytes(state_t *state) {
	for(uint8_t i=0; i<4; ++i)
		for(uint8_t j=0; j<4; ++j)
			(*state)[j][i] = rsbox[(*state)[j][i]];
}

uint8_t Multiply(uint8_t x, uint8_t y) {
	return (((y & 1) * x) ^
		 ((y>>1 & 1) * xtime2(x)) ^
		 ((y>>2 & 1) * xtime2(xtime2(x))) ^
		 ((y>>3 & 1) * xtime2(xtime2(xtime2(x)))) ^
		 ((y>>4 & 1) * xtime2(xtime2(xtime2(xtime2(x))))));
}

void InvMixColumns(state_t *state) {
	for(uint8_t i=0; i<4; ++i) {
		uint8_t a = (*state)[i][0];
		uint8_t b = (*state)[i][1];
		uint8_t c = (*state)[i][2];
		uint8_t d = (*state)[i][3];

		(*state)[i][0] = Multiply(a, 0x0e) ^ Multiply(b, 0x0b) ^ Multiply(c, 0x0d) ^ Multiply(d, 0x09);
		(*state)[i][1] = Multiply(a, 0x09) ^ Multiply(b, 0x0e) ^ Multiply(c, 0x0b) ^ Multiply(d, 0x0d);
		(*state)[i][2] = Multiply(a, 0x0d) ^ Multiply(b, 0x09) ^ Multiply(c, 0x0e) ^ Multiply(d, 0x0b);
		(*state)[i][3] = Multiply(a, 0x0b) ^ Multiply(b, 0x0d) ^ Multiply(c, 0x09) ^ Multiply(d, 0x0e);
	}
}

void InvCipher(state_t *state, uint8_t ***round_key) {
	AddRoundKey(Nr, state, round_key);
	for(uint8_t round=(Nr-1);; --round) {
		InvShiftRows(state);
		InvSubBytes(state);
		AddRoundKey(round, state, round_key);

		if(round == 0)
			break;

		InvMixColumns(state);
	}
}

void XorWithState(state_t *buffer, uint8_t *iv) {
	for(uint8_t i=0; i<4; ++i)
		for(uint8_t j=0; j<4; ++j)
			(*buffer)[i][j] ^= iv[i*4 + j];
}

/**********************************************************************************/

__kernel void aes_cbc_encrypt(__global uint8_t *key,
							  __global uint8_t *plaintext,
							  uint32_t data_length,
							  __global uint8_t *iv,
							  __local uint8_t *queue,
							  uint32_t id,
							  uint32_t group_size)
{
	uint8_t key_round[KeyExpSize];
	uint8_t key_local[KeyLen];
	for(int i=0; i<KeyLen; i++)
		key_local[i] = key[i];

	KeyExpansion(&key_round, &key_local);

	size_t range = data_length / 16 > group_size ? (data_length / 16) / group_size : 1;
	size_t offset = id * range * 16;

	state_t state;

	if(id != 0)
		for(uint8_t i=0; i<4; ++i)
			for(uint8_t j=0; j<4; ++j)
				state[i][j] = queue[i*4 + j];

	for(size_t i=offset; i<(offset + range * 16); i+=16) {
		if(i == 0)
			for(uint8_t j=0; j<4; ++j)
				for(uint8_t k=0; k<4; ++k)
					state[j][k] = iv[j*4 + k];

		uint8_t buffer[BlockSize];
		for(size_t j=0; j<BlockSize; ++j)
			buffer[j] = plaintext[i+j];

		XorWithState(&state, &buffer);
		Cipher(*state, &key_round);

		for(size_t j=0; j<4; ++j)
			for(size_t k=0; k<4; ++k)
				plaintext[i+j*4+k] = state[j][k];
	}

	for(uint8_t i=0; i<4; ++i)
		for(uint8_t j=0; j<4; ++j)
			queue[i*4 + j] = state[i][j];
}

// TODO: parallel
__kernel void aes_cbc_decrypt(__global uint8_t *key,
							  __global uint8_t *plaintext,
							  uint32_t data_length,
							  __global uint8_t *iv,
							  __local uint8_t *queue,
							  uint32_t id,
							  uint32_t group_size)
{
	uint8_t key_round[KeyExpSize];
	uint8_t key_local[KeyLen];
	for(int i=0; i<KeyLen; i++)
		key_local[i] = key[i];

	KeyExpansion(&key_round, &key_local);

	size_t range = data_length / 16 > group_size ? (data_length / 16) / group_size : 1;
	size_t offset = id * range * 16;

	if(id == 0)
		for(uint8_t i=0; i<BlockSize; ++i)
			queue[i] = plaintext[i];

	for(size_t i=offset; i<(offset + range * 16); i+=16) {
		uint8_t buffer[BlockSize];
		for(uint8_t j=0; j<BlockSize; ++j) {
			if(i == 0)
				buffer[j] = iv[j];
			else
				buffer[j] = queue[j];
		}

		for(uint8_t j=0; j<BlockSize; ++j)
			queue[j] = plaintext[offset + j];

		state_t  state;
		for(uint8_t j=0; j<4; ++j)
			for(uint8_t k=0; k<4; ++k)
				state[j][k] = plaintext[offset + j*4 + k];

		InvCipher(*state, &key_round);
		XorWithState(*state, &buffer);

		for(size_t j=0; j<4; ++j)
			for(size_t k=0; k<4; ++k)
				plaintext[i+j*4+k] = state[j][k];
	}
}

// TODO: fix
__kernel void aes_cfb_encrypt(__global uint8_t *key,
							  __global uint8_t *plaintext,
							  uint32_t data_length,
							  __global uint8_t *iv,
							  __local uint8_t *queue,
							  uint32_t id,
							  uint32_t group_size)
{
	uint8_t key_round[KeyExpSize];
	uint8_t key_local[KeyLen];
	for(int i=0; i<KeyLen; i++)
		key_local[i] = key[i];

	KeyExpansion(&key_round, &key_local);

	size_t range = data_length / 16 > group_size ? (data_length / 16) / group_size : 1;
	size_t offset = id * range * 16;

	state_t state;

	if(id != 0)
		for(uint8_t i=0; i<4; ++i)
			for(uint8_t j=0; j<4; ++j)
				state[i][j] = queue[i*4 + j];

	for(size_t i=offset; i<(offset + range * 16); i+=16) {
		if(i == 0)
			for(uint8_t j=0; j<4; ++j)
				for(uint8_t k=0; k<4; ++k)
					state[j][k] = iv[j*4 + k];

		uint8_t buffer[BlockSize];
		for(size_t j=0; j<BlockSize; ++j)
			buffer[j] = plaintext[i+j];

		Cipher(*state, &key_round);
		XorWithState(&state, &buffer);


		for(size_t j=0; j<4; ++j)
			for(size_t k=0; k<4; ++k)
				plaintext[i+j*4+k] = state[j][k];
	}

	for(uint8_t i=0; i<4; ++i)
		for(uint8_t j=0; j<4; ++j)
			queue[i*4 + j] = state[i][j];
}

// TODO: parallel
__kernel void aes_cfb_decrypt()
{

}

__kernel void aes_ofb(__global uint8_t *key,
							  __global uint8_t *plaintext,
							  uint32_t data_length,
							  __global uint8_t *iv,
							  __local uint8_t *queue,
							  uint32_t id,
							  uint32_t group_size)
{
	uint8_t key_round[KeyExpSize];
	uint8_t key_local[KeyLen];
	for(int i=0; i<KeyLen; i++)
		key_local[i] = key[i];

	KeyExpansion(&key_round, &key_local);

	size_t range = data_length / 16 > group_size ? (data_length / 16) / group_size : 1;
	size_t offset = id * range * 16;

	state_t state;

	if(id != 0)
		for(uint8_t i=0; i<4; ++i)
			for(uint8_t j=0; j<4; ++j)
				state[i][j] = queue[i*4 + j];

	for(size_t i=offset; i<(offset + range * 16); i+=16) {
		if(i == 0)
			for(uint8_t j=0; j<4; ++j)
				for(uint8_t k=0; k<4; ++k)
					state[j][k] = iv[j*4 + k];

		uint8_t buffer[BlockSize];
		for(size_t j=0; j<BlockSize; ++j)
			buffer[j] = plaintext[i+j];

		Cipher(*state, &key_round);

		state_t  state2;
		for(uint8_t j=0; j<4; ++j)
			for(uint8_t k=0; k<4; ++k)
				state2[j][k] = state[j][k];

		XorWithState(*state2, &buffer);


		for(size_t j=0; j<4; ++j)
			for(size_t k=0; k<4; ++k)
				plaintext[i+j*4+k] = state2[j][k];
	}

	for(uint8_t i=0; i<4; ++i)
		for(uint8_t j=0; j<4; ++j)
			queue[i*4 + j] = state[i][j];
}

// TODO: parallel
__kernel void aes_ctr(__global uint8_t *key,
					  __global uint8_t *plaintext,
					  uint32_t data_length,
					  __global uint8_t *iv,
					  __local uint8_t *queue,
					  uint32_t id,
					  uint32_t group_size)
{
	uint8_t key_round[KeyExpSize];
	uint8_t key_local[KeyLen];
	for(uint8_t i=0; i<KeyLen; ++i)
		key_local[i] = key[i];

	KeyExpansion(&key_round, &key_local);

	uint32_t range = data_length / 16 > group_size ? (data_length / 16) / group_size : 1;
	size_t offset = id * range * 16;

	for(uint32_t i=0; i<range; i+=16) {
		state_t state;

		for(uint8_t j=0; j<BlockSize/2; ++j)
			for(uint8_t k=0; k<BlockSize; ++k)
				state[j][k] = iv[j*4 + k];

		state[2][0] = 0; state[2][1] = 0; state[2][2] = 0; state[2][3] = 0;

		uint32_t a_mask = 0xFF000000;
		uint32_t b_mask = 0x00FF0000;
		uint32_t c_mask = 0x0000FF00;
		uint32_t d_mask = 0x000000FF;

		uint32_t counter = id * range + i;

		state[3][0] = (uint8_t)((counter & a_mask) >> 24);
		state[3][1] = (uint8_t)((counter & b_mask) >> 16);
		state[3][2] = (uint8_t)((counter & c_mask) >> 8);
		state[3][3] = (uint8_t)((counter & d_mask));

		Cipher(*state, &key_round);

		uint8_t buffer[BlockSize];
		for(uint8_t j=0; j<BlockSize; ++j)
			buffer[j] = plaintext[offset + j];

		XorWithState(*state, buffer);

		for(uint8_t j=0; j<4; j++)
			for(uint8_t k=0; k<4; ++k)
				plaintext[offset +j*4 + k] = state[j][k];
	}
}

__kernel void aes_ecb_encrypt(__global uint8_t *key,
							  __global uint8_t *plaintext,
							  uint32_t data_length)
{
	size_t id = get_global_id(0);
	size_t size = get_global_size(0);

	uint8_t key_round[KeyExpSize];
	uint8_t key_local[KeyLen];
	for(int i=0; i<KeyLen; i++)
		key_local[i] = key[i];

	KeyExpansion(&key_round, &key_local);

	size_t range = data_length / 16 > size ? (data_length / 16) / size : 1;
	size_t offset = id * range * 16;

	for(size_t i=offset; i<(offset + range * 16); i+=16) {
		state_t point;
		for(int j = 0; j<4; j++)
			for(int k = 0; k<4; k++)
				point[j][k] = plaintext[i+j*4+k];

		Cipher(*point, &key_round);

		for(int j = 0; j<4; j++)
			for(int k = 0; k<4; k++)
				plaintext[i+j*4+k] = point[j][k];
	}
}

__kernel void aes_ecb_decrypt(__global uint8_t *key,
							  __global uint8_t *plaintext,
							  uint32_t data_length)
{
	size_t id = get_global_id(0);
	size_t size = get_global_size(0);

	uint8_t key_round[KeyExpSize];
	uint8_t key_local[KeyLen];
	for(int i=0; i<KeyLen; i++)
		key_local[i] = key[i];

	KeyExpansion(&key_round, &key_local);

	size_t range = data_length / 16 > size ? (data_length / 16) / size : 1;
	size_t offset = id * range * 16;

	for(size_t i=offset; i<(offset + range * 16); i+=16) {
		state_t point;
		for(int j = 0; j<4; j++) {
			for(int k = 0; k<4; k++) {
				point[j][k] = plaintext[i+j*4+k];
			}
		}

		InvCipher(*point, &key_round);

		for(int j = 0; j<4; j++)
			for(int k = 0; k<4; k++)
				plaintext[i+j*4+k] = point[j][k];
	}
}
