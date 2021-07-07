static void perm_init(char perm[8][256][8], char p[64]){
    int i, j, n, bit, byte;
    int B8;
    memset(perm, 0, 8*256*8);
    for (i=0;i<8;i++){ // 按表打乱并分散
		for (B8=0;B8<256;B8++){
            for (j=0;j<64;j++){
                n = p[j] - 1;
                if ((n / 8) != i){
                	continue;
				}
				if (!(B8 & bytebit[n % 8])){
					continue; // 该位不等于1
				}
				byte = j / 8;
				bit = j & 7;
				perm[i][B8][byte] |= bytebit[bit]; // 该位等于1，则对应位置1
            }
        }
    }
}

static void permute(char *inblock, char perm[8][256][8], char *outblock){
    int i, j;
    char *p;
	unsigned char B8;
    memset(outblock, 0, 8);
    for (i=0;i<8;i++){
        B8 = inblock[i]; // 对应的哪一种变化
        p = perm[i][B8];
        for (j=0;j<8;j++){
            outblock[j] |= p[j]; // 或操作
        }
    }
}

int des_init(int mode){ // 修改了iperm和fperm的内存分配
   if(sbox_output_perm_table != NULL){
      return 1;
   }
   des_mode = mode;
   if((sbox_output_perm_table = (long32 (*)[64])malloc(sizeof(long32) * 8 * 64)) == NULL){
      return 0;
   }
   sbox_output_perm_table_init();
   kn = (unsigned char (*)[8])malloc(sizeof(char) * 16 * 8);
   if(kn == NULL){
      free((char *)sbox_output_perm_table);
      return 0;
   }
   if(mode == 1 || mode == 2)
      return 1;

   iperm = (char (*)[256][8])malloc(sizeof(char) * 8 * 256 * 8);
   if(iperm == NULL){
      free((char *)sbox_output_perm_table);
      free((char *)kn);
      return 0;
   }
   perm_init(iperm, ip);

   fperm = (char (*)[256][8])malloc(sizeof(char) * 8 * 256 * 8);
   if(fperm == NULL){
      free((char *)sbox_output_perm_table);
      free((char *)kn);
      free((char *)iperm);
      return 0;
   }
   perm_init(fperm, fp);   
   return 1;
}
