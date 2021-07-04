#include <stdio.h>
#include <string.h>
#include <openssl/rsa.h>
#include <openssl/rand.h>
#include <openssl/bn.h>
#include <openssl/ec.h>
#include <openssl/sha.h>

#pragma comment(lib, "libeay32.lib")
#pragma comment(lib, "ssleay32.lib")

char A[0x100], B[0x100], PE[0x100];   // ecc曲线参数a, b, p
char GX[0x100], GY[0x100], NE[0x100]; // 基点G的x坐标, y坐标, G的阶(均为256位)
char DE[0x100];                       // ecc的私钥d(256位)
char N1[2][0x100], D1[2][0x100], X2[2][0x100]; 
                // N1存放用ecc公钥加密过的rsa参数N, 
                // 其中N1[0]存放第1部分密文, N1[1]存放第2部分密文;
                // D1存放用ecc公钥加密过的rsa私钥d;
                // X2存放用ecc公钥加密过的X1
char X1[0x100]; // X1存放用rsa公钥加密过的X                      
char X[0x100];  // X存放一个256位的随机数, X<N 且 X<NE
char N[0x100], D[0x100];       // rsa的N及私钥d(256位)
char RX[0x100], RY[0x100];     // ecc公钥R的x坐标及y坐标 
char C[2][0x100]; // 存放用ecc公钥加密过的X, C[0]是第1部分密文, C[1]是第2部分密文
char S[2][0x100]; // 存放用ecnr签名过的RSA_private_encrypt_PKCS1_type_2(SHA1(X), D)
                  // 其中SHA1是散列算法, RSA_private_encrypt_PKCS1_type_2()是用RSA的
                  // 私钥d对SHA1(X)进行加密(实际上是签名), 加密前必须对SHA1(X)按PKCS1_type_2
                  // 方式进行填充, 使得SHA1(X)的长度从20字节变成0x20字节(即256位);
                  // 针对N为256位的PKCS1_type_2填充格式如下:
                  // 0x00, 0x02, 9字节非零随机数, 0x00, 20字节明文
                  // 归纳起来讲, S是对SHA1(X)的两次签名, 第1次是用rsa的私钥签名, 第2次是用ecc的私钥签名

// 1、解出X、N、D;
// 2、用ecc的公钥对X进行加密, 结果保存到C中;
// 3、用rsa的私钥对SHA1(X)进行签名, 再用ecc的ecnr算法对rsa签名再作一次签名,结果保存在S中;
// 4、输出C[0], C[1], S[0], S[1] 

int main()
{
	EC_GROUP *group;
   	BN_CTX *ctx;
   	EC_POINT *G, *T, *R; // G是基点, T是临时点, R是公钥点
    BIGNUM *p, *a, *b, *n, *gx, *gy, *tx, *ty;
   	BIGNUM *m, *d, *r, *s, *k; // m是明文, d是私钥, r是密文的第一部分, s是密文的第二部分
   	BIGNUM *rsan, *rsad, *rsae; // RSA解密参数
	RSA *prsa = RSA_new(); // RSA秘钥
	char MX[0x100]; // SHA1(X)
    char X3[0x100]; // 填充后的SHA1(X)
	char X4[0x100];
	long ticks;
   	int i, len;
    
    scanf("%s", A); // inputs
    scanf("%s", B);
    scanf("%s", PE);
    scanf("%s", GX);
    scanf("%s", GY);
    scanf("%s", NE);
    scanf("%s", DE);
    scanf("%s", N1[0]);
    scanf("%s", N1[1]);
    scanf("%s", D1[0]);
    scanf("%s", D1[1]);
    scanf("%s", X2[0]);
    scanf("%s", X2[1]);
    
    
    a = BN_new(); // 分配内存 
    b = BN_new();  
	p = BN_new(); 
	gx = BN_new();
    gy = BN_new();
    n = BN_new();  
	d = BN_new();
    tx = BN_new();
    ty = BN_new();
    r = BN_new();
    s = BN_new();
    m = BN_new(); // m保存解密出来的明文 
    k = BN_new();
	rsan = BN_new();
	rsae = BN_new();
	rsad = BN_new();
    
    BN_hex2bn(&a, A);
    BN_hex2bn(&b, B); // 系数 
    BN_hex2bn(&p, PE); // mod p 
    BN_hex2bn(&gx, GX);
    BN_hex2bn(&gy, GY); // 基点的坐标 
	BN_hex2bn(&n, NE); // 阶 
    BN_hex2bn(&d, DE); // 私钥 
    
    group = EC_GROUP_new(EC_GFp_mont_method());
    ctx = BN_CTX_new();
    EC_GROUP_set_curve_GFp(group, p, a, b, ctx); // 群 
    
    G = EC_POINT_new(group); 
   	EC_POINT_set_affine_coordinates_GFp(group, G, gx, gy, ctx); // 设置基点坐标 
   	EC_GROUP_set_generator(group, G, n, BN_value_one()); // 基点=G, G的阶=n, 余因子=1
    
    T = EC_POINT_new(group); // 临时点 
    
	// 先解 N
    BN_hex2bn(&r, N1[0]); 
	BN_hex2bn(&s, N1[1]); 
    
    EC_POINT_set_compressed_coordinates_GFp(group, T, r, 0, ctx); // 由横坐标求出完整的 T=r
	EC_POINT_mul(group, T, NULL, T, d, ctx); // T = d*r
   	EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); // tx = (d*r).x 
   	BN_mod_inverse(tx, tx, n, ctx); // tx = tx^-1 = (d*r).x ^ -1
   	BN_clear(rsan);
   	BN_mod_mul(rsan, s, tx, n, ctx); // rsan = s/(d*r).x
   	memset(N, 0, sizeof(N)); 
   	BN_bn2bin(rsan, N); // 将求得的 N 保存进数组
    
	// 解 rsa 的私钥 d
    BN_hex2bn(&r, D1[0]);  
	BN_hex2bn(&s, D1[1]); 
    
    EC_POINT_set_compressed_coordinates_GFp(group, T, r, 0, ctx); // 由横坐标求出完整的 T=r
	EC_POINT_mul(group, T, NULL, T, d, ctx); // T = d*r
   	EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); // tx = (d*r).x 
   	BN_mod_inverse(tx, tx, n, ctx); // tx = tx^-1 = (d*r).x ^ -1
   	BN_clear(rsad);
   	BN_mod_mul(rsad, s, tx, n, ctx); // rsad = s/(d*r).x
   	memset(D, 0, sizeof(D)); 
   	BN_bn2bin(rsad, D); // 将求得的 D 保存进数组
   	
	// 解 X1 
   	BN_hex2bn(&r, X2[0]); 
	BN_hex2bn(&s, X2[1]); 

	EC_POINT_set_compressed_coordinates_GFp(group, T, r, 0, ctx); // 由横坐标求出完整的 T=r
	EC_POINT_mul(group, T, NULL, T, d, ctx); // T = d*r
   	EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); // tx = (d*r).x 
   	BN_mod_inverse(tx, tx, n, ctx); // tx = tx^-1 = (d*r).x ^ -1
   	BN_clear(m);
   	BN_mod_mul(m, s, tx, n, ctx); // m = s/(d*r).x
   	
   	memset(X1, 0, sizeof(X1)); 
   	BN_bn2bin(m, X1); // 将求得的 X1 保存进数组
   	
	// 生成 RSA 秘钥
	prsa = RSA_new();
	prsa->flags |= RSA_FLAG_NO_BLINDING; // 关闭blinding模式
	prsa->n = rsan;
	prsa->d = rsad;
	prsa->e = NULL;
	RSA_private_decrypt(32, X1, X, prsa, RSA_NO_PADDING); // RSA 解密求 X, 此时 X 每个字节的ASCII码为所求

    // 用ecc的公钥加密 X
	R = EC_POINT_new(group); // 公钥点 
    EC_POINT_mul(group, R, d, NULL, NULL, ctx); // 公钥 R = d*G
    EC_POINT_get_affine_coordinates_GFp(group, R, tx, ty, ctx); // tx, ty 保存了 R 的坐标 
    strcpy(RX, BN_bn2hex(tx));
    strcpy(RY, BN_bn2hex(ty)); // 保存 R 的横纵坐标 
    
    // 产生随机数 
	ticks = (long)time(NULL);
	RAND_add(&ticks, sizeof(ticks), 1);
	BN_rand(k, BN_num_bits(n), 0, 0); // 产生随机数k
    
    // 加密
	EC_POINT_mul(group, T, k, NULL, NULL, ctx); // T = k*G 
	EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); // tx = (k*G).x 
    BN_copy(r, tx); // 密文第一部分
	EC_POINT_mul(group, T, NULL, R, k, ctx); // T = k*R
    EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); // tx = (k*R).x
    BN_bin2bn(X, BN_num_bytes(n), m); // m = X
    BN_mod_mul(s, m, tx, n, ctx); // s = 密文第二部分 
    strcpy(C[0], BN_bn2hex(r));
    strcpy(C[1], BN_bn2hex(s)); // 保存加密后的 X 
	
	puts(C[0]);
    puts(C[1]);
    
	memset(MX, 0, sizeof(MX));
    SHA1(X, 32, MX); // MX = SHA1(X)

	// 填充
	memset(X3, 0, sizeof(X3));
	X3[0] = 0x00;
	X3[1] = 0x02;
	for (i=2; i<11; i++){
		ticks = (long)time(NULL);
		srand((unsigned int)ticks); 
		X3[i] = (char)rand();
	} // 9字节随机数
	X3[11] = 0x00;
	for (i=12; i<32; i++){
		X3[i] = MX[i-12];
	}

	len = RSA_size(prsa);
	memset(X4, 0, sizeof(X4));
    RSA_private_encrypt(len, X3, X4, prsa, RSA_NO_PADDING); // 用RSA的私钥对SHA1(X)进行一次加密 
    
    // 产生随机数 
	ticks = (long)time(NULL);
	RAND_add(&ticks, sizeof(ticks), 1);
	BN_rand(k, BN_num_bits(n), 0, 0); // 产生随机数k
    
    // ecnr 签名 
    EC_POINT_mul(group, T, k, NULL, NULL, ctx); // T = k*G 
	EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); // tx = (k*G).x 
	BN_mod(tx, tx, n, ctx);  // tx = (k*G).x mod n
    BN_bin2bn(X4, BN_num_bytes(n), m); // m = RSA加密后的SHA1(X) 
    BN_add(r, tx, m); // r = (k*G).x + m 
    BN_mod(r, r, n, ctx);  // 签名第一部分
	memset(S[0], 0, sizeof(S[0])); 
   	strcpy(S[0], BN_bn2hex(r)); // 将求得的签名保存进数组
   	
   	BN_mod_mul(s, r, d, n, ctx); // s = r*d mod n
    BN_set_negative(s, 1); // s = -(r*d)
    BN_add(s, n, s); // s = n-(r*d)
    BN_mod_add(s, k, s, n, ctx); // 签名第二部分
	memset(S[1], 0, sizeof(S[1])); 
   	strcpy(S[1], BN_bn2hex(s)); // 将求得的签名保存进数组
   	
    puts(S[0]);
    puts(S[1]);
    
    return 0;
}