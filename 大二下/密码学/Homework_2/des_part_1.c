static long32 f(ulong32 r, unsigned char subkey[8]){
    unsigned char s[4], plaintext[8], m[4], t[4];
    unsigned long int rval;
    int i, j;
    int n, byte, bit;
    int x, y;
    // (1) 复制r到s中
    memset(s, 0, sizeof(s));
    for (i=3;i>=0;i--){
    	s[i] = (r >> 8*(3-i)) & 255;
	}
    // (2) 扩展到48位
    memset(plaintext, 0, sizeof(plaintext));
    for (i=0;i<8;i++){
        for (j=0;j<6;j++){
            n = plaintext_32bit_expanded_to_48bit_table[6*i+j]-1;
            byte = n / 8; // 第几个字节
            bit = n % 8; // 第几位
            if (s[byte] & bytebit[bit]){
                plaintext[i] |= bytebit[(j+2)%8]; // 左边两位恒为0
            }
        }
    }
    // (3) 8次异或
    for (i=0;i<8;i++){
        plaintext[i] ^= subkey[i];
    }
    // (4) 查询sbox
    memset(m, 0, sizeof(m));
    for (i=0;i<8;i++){
        x = 0; // 行
        y = 0; // 列
        if (plaintext[i] & bytebit[2]){
            x += 2;
        }
        if (plaintext[i] & bytebit[7]){
            x += 1;
        }
        y = (plaintext[i] & 0x1E) >> 1;
        m[i/2] |= sbox[i][16*x+y] << (i % 2 == 0 ? 4 : 0); // 合并
    }
    // (5) 打乱m中的32位数
    memset(t, 0, sizeof(t));
    for (i=0;i<32;i++){
        n = sbox_perm_table[i] - 1;
        byte = n / 8;
        bit = n % 8;
        if (m[byte] & bytebit[bit]){
            t[i/8] |= bytebit[i%8];
        }
    }
    // (6) 复制并返回rval
    rval = 0;
    for (i=0;i<4;i++){
    	rval |= t[i] << 8*(3-i);
	}
    return rval;
}
