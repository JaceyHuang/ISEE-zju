
/*
This program is written by Black White(iceman@zju.edu.cn), and 
is for teaching purpose. Please do not upload it to anywhere 
outside Zhejiang University.

192-bit key:
#define A  "-3"
#define B  "64210519E59C80E70FA7E9AB72243049FEB8DEECC146B9B1"
#define P  "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFF"
#define Gx "188DA80EB03090F67CBF20EB43A18800F4FF0AFD82FF1012"
#define Gy "07192B95FFC8DA78631011ED6B24CDD573F977A11E794811"
#define Q  "FFFFFFFFFFFFFFFFFFFFFFFF99DEF836146BC9B1B4D22831"
#define D  "97B27EA7BB8A6639601888965DC22BA3287E31D9"
*/

#include <stdio.h>
#include <string.h>
#include <openssl/rsa.h>
#include <openssl/rand.h>
#include <openssl/bn.h>
#include <openssl/ec.h>
#pragma comment(lib, "libeay32.lib")
#pragma comment(lib, "ssleay32.lib")

#define A  "-3"                                               /* coefficient a */
        /* "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFC" is equal to "-3" */
#define B  "64210519E59C80E70FA7E9AB72243049FEB8DEECC146B9B1" /* coefficient b */
#define P  "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFF" /* mod P=192-bit */
#define GX "188DA80EB03090F67CBF20EB43A18800F4FF0AFD82FF1012" /* base point G's */
#define GY "07192B95FFC8DA78631011ED6B24CDD573F977A11E794811" /* coordinates(Gx,Gy) */
#define N  "FFFFFFFFFFFFFFFFFFFFFFFF99DEF836146BC9B1B4D22831" /* order N=192-bit */
#define D  "CADDC27FEFC3040C1CCA194542218E002F58D504A639B668" /* private key D */

void dump_ecc(EC_GROUP *group)
{
   BIGNUM *a, *b, *p, *n, *h, *gx, *gy;
   BN_CTX *ctx;
   const EC_POINT *G; 
   int bits_of_p;

   p = BN_new();
   a = BN_new();
   b = BN_new();
   n = BN_new();
   h = BN_new();
   gx = BN_new();
   gy = BN_new();
   ctx = BN_CTX_new();

   EC_GROUP_get_curve_GFp(group, p, a, b, ctx);
   G = EC_GROUP_get0_generator(group);
   EC_POINT_get_affine_coordinates_GFp(group, G, gx, gy, ctx);
   EC_GROUP_get_order(group, n, ctx);
   EC_GROUP_get_cofactor(group, h, ctx);
   bits_of_p = EC_GROUP_get_degree(group);
   puts("Curve defined by Weierstrass equation: y^2 = x^3 + a*x + b  (mod p)");
   printf("a=%s\n", BN_bn2hex(a));
   printf("b=%s\n", BN_bn2hex(b));
   printf("p=%s\n", BN_bn2hex(p));
   printf("base point G=(%s, \n%s)\n", BN_bn2hex(gx), BN_bn2hex(gy));
   printf("order of G, i.e. n=%s\n", BN_bn2hex(n));
   printf("cofactor=points on curve/order of G, i.e. h=%s\n", BN_bn2hex(h));
   printf("bits of p=0x%04X=%d\n", bits_of_p, bits_of_p);

   BN_free(p);
   BN_free(a);
   BN_free(b);
   BN_free(n);
   BN_free(h);
   BN_free(gx);
   BN_free(gy);
   BN_CTX_free(ctx);
}

void dump_hex(unsigned char *p, int n, unsigned char *q)
{
   int i;
   for(i=0; i<n; i++)
   {
      sprintf((char *)&q[i*2], "%02X", p[i]);
   }
   q[i*2] = '\0';
}

void scan_hex(unsigned char *p, int n, unsigned char *q)
{
   int i;
   for(i=0; i<n; i++)
   {
      sscanf((char *)&p[i*2], "%02X", &q[i]);
   }
}


void ecnr_sign_verify(void)
{  /* Nyberg Rueppel */
   unsigned char plaintext[256] = "A QuickBrownFox+ALazyDog"; /* 24 bytes = 192 bits */
   unsigned char ciphertext[512];
   unsigned char bufin[256];
   unsigned char bufout[256];
   unsigned char hex[256];
   long ticks;
   int  ciphertext_len;
   EC_GROUP *group;
   BN_CTX *ctx;
   EC_POINT *G, *T, *R, *PT1, *PT2;       /* G是基点, T,PT1,PT2是临时点, R是公钥点 */
   BIGNUM *p, *a, *b, *n, *gx, *gy, *tx, *ty;
   BIGNUM *m, *d, *k, *r, *s; /* m是明文, d是私钥, k是随机数, r及s是密文 */

   p = BN_new();
   a = BN_new();
   b = BN_new();  /* a,b,p决定曲线 */
   n = BN_new();  /* n是基点G的阶 */
   gx = BN_new(); /* 基点G的x坐标 */
   gy = BN_new(); /* 基点G的y坐标 */
   tx = BN_new(); /* 临时点T的x坐标 */
   ty = BN_new(); /* 临时点T的y坐标 */
   m = BN_new();  /* m是明文 */
   d = BN_new();  /* d是私钥 */
   k = BN_new();  /* k是随机数 */
   r = BN_new();  /* r是签名第1部分 */
   s = BN_new();  /* s是签名第2部分 */


   BN_hex2bn(&a, A);
   BN_hex2bn(&b, B);
   BN_hex2bn(&p, P);
   BN_hex2bn(&n, N);
   BN_hex2bn(&gx, GX);
   BN_hex2bn(&gy, GY);
   BN_hex2bn(&d, D);

   group = EC_GROUP_new(EC_GFp_mont_method()); /* 或EC_GFp_simple_method(); mont: BN_mod_mul_montgomery */
   ctx = BN_CTX_new();
   EC_GROUP_set_curve_GFp(group, p, a, b, ctx);

   G = EC_POINT_new(group);
   EC_POINT_set_affine_coordinates_GFp(group, G, gx, gy, ctx);
   EC_GROUP_set_generator(group, G, n, BN_value_one()); /* 基点=G, G的阶=n, 余因子=1 */
   dump_ecc(group);

   R = EC_POINT_new(group);
   EC_POINT_mul(group, R, d, NULL, NULL, ctx); /* 公钥R = d*G; d是私钥 */
   EC_POINT_get_affine_coordinates_GFp(group, R, tx, ty, ctx); /* tx = (d*G).x */
   printf("R.x=%s\nR.y=%s\n", BN_bn2hex(tx), BN_bn2hex(ty)); /* 输出公钥 */
   printf("d=%s\n", BN_bn2hex(d)); /* 输出私钥 */

   ticks = (long)time(NULL);
   RAND_add(&ticks, sizeof(ticks), 1); /* srand() */
   BN_rand(k, BN_num_bits(n), 0, 0);   /* 产生随机数k, 位数与n相等 */

   T = EC_POINT_new(group);
   EC_POINT_mul(group, T, k, NULL, NULL, ctx); /* T = k*G */

   EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); /* tx = (k*G).x */
   BN_mod(tx, tx, n, ctx);  /* tx = (k*G).x mod n */
   BN_bin2bn(plaintext, BN_num_bytes(n), m); /* m = plaintext */
   BN_add(r, tx, m); /* r = (k*G).x + m */
   BN_mod(r, r, n, ctx);  /* r = 签名第1部分 = ((k*G).x + m) mod n */

   BN_mod_mul(s, r, d, n, ctx); /* s = r*d mod n */
   BN_set_negative(s, 1); /* s = -(r*d) */
   BN_add(s, n, s); /* s = n-(r*d) */
   BN_mod_add(s, k, s, n, ctx); /* s = 签名第2部分 = (k-r*d) mod n */
   printf("signature=\n%s;\n%s;\n", BN_bn2hex(r), BN_bn2hex(s));

   puts("Verifying...");
   PT1 = EC_POINT_new(group);
   PT2 = EC_POINT_new(group);

   EC_POINT_mul(group, PT1, s, NULL, NULL, ctx); /* PT1=s*G */
   EC_POINT_mul(group, PT2, NULL, R, r, ctx); /* PT2=r*R */
   EC_POINT_add(group, T, PT1, PT2, ctx); /* T = s*G+r*R
                                               = (k-r*d)*G + r*R
                                               = kG-rdG+rdG
                                               = kG
                                           */
   
   EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); /* tx=kG.x */
   BN_mod(tx, tx, n, ctx);  /* tx = kG.x mod n */
   BN_set_negative(tx, 1); /* tx = -kG.x */
   BN_add(tx, n, tx); /* tx = n-kG.x */
   BN_mod_add(tx, r, tx, n, ctx); /* tx = r-kG.x = kG.x + m - kG.x = m */

   printf("(r-(s*G+r*R)) mod n=\n%s\n", BN_bn2hex(tx));
   //memset(plaintext, 0, sizeof(plaintext));
   //BN_bn2bin(tx, plaintext);
   //puts((char *)plaintext);

   if(BN_ucmp(tx, m)==0)
      puts("The signature is correct.");
   else
      puts("The signature is incorrect.");
   BN_free(p);
   BN_free(a);
   BN_free(b); 
   BN_free(n); 
   BN_free(gx);
   BN_free(gy);
   BN_free(tx);
   BN_free(ty);
   BN_free(m); 
   BN_free(d); 
   BN_free(k); 
   BN_free(r); 
   BN_free(s); 
   EC_POINT_free(G);
   EC_POINT_free(R);
   EC_POINT_free(T);
   EC_POINT_free(PT1);
   EC_POINT_free(PT2);
   BN_CTX_free(ctx);
   EC_GROUP_free(group);
}


void ecdsa_sign_verify(void)
{
   unsigned char plaintext[256] = "A QuickBrownFox+ALazyDog"; /* 24 bytes = 192 bits */
   unsigned char ciphertext[512];
   unsigned char bufin[256];
   unsigned char bufout[256];
   unsigned char hex[256];
   long ticks;
   int  ciphertext_len;
   EC_GROUP *group;
   BN_CTX *ctx;
   EC_POINT *G, *T, *R, *PT1, *PT2;       /* G是基点, T,PT1,PT2是临时点, R是公钥点 */
   BIGNUM *p, *a, *b, *n, *gx, *gy, *tx, *ty;
   BIGNUM *m, *d, *k, *r, *s; /* m是明文, d是私钥, k是随机数, r及s是密文 */

   p = BN_new();
   a = BN_new();
   b = BN_new();  /* a,b,p决定曲线 */
   n = BN_new();  /* n是基点G的阶 */
   gx = BN_new(); /* 基点G的x坐标 */
   gy = BN_new(); /* 基点G的y坐标 */
   tx = BN_new(); /* 临时点T的x坐标 */
   ty = BN_new(); /* 临时点T的y坐标 */
   m = BN_new();  /* m是明文 */
   d = BN_new();  /* d是私钥 */
   k = BN_new();  /* k是随机数 */
   r = BN_new();  /* r是签名第1部分 */
   s = BN_new();  /* s是签名第2部分 */


   BN_hex2bn(&a, A);
   BN_hex2bn(&b, B);
   BN_hex2bn(&p, P);
   BN_hex2bn(&n, N);
   BN_hex2bn(&gx, GX);
   BN_hex2bn(&gy, GY);
   BN_hex2bn(&d, D);

   group = EC_GROUP_new(EC_GFp_mont_method()); /* 或EC_GFp_simple_method(); mont: BN_mod_mul_montgomery */
   ctx = BN_CTX_new();
   EC_GROUP_set_curve_GFp(group, p, a, b, ctx);

   G = EC_POINT_new(group);
   EC_POINT_set_affine_coordinates_GFp(group, G, gx, gy, ctx);
   EC_GROUP_set_generator(group, G, n, BN_value_one()); /* 基点=G, G的阶=n, 余因子=1 */
   dump_ecc(group);

   R = EC_POINT_new(group);
   EC_POINT_mul(group, R, d, NULL, NULL, ctx); /* 公钥R = d*G; d是私钥 */
   EC_POINT_get_affine_coordinates_GFp(group, R, tx, ty, ctx); /* tx = (d*G).x */
   printf("R.x=%s\nR.y=%s\n", BN_bn2hex(tx), BN_bn2hex(ty)); /* 输出公钥 */
   printf("d=%s\n", BN_bn2hex(d)); /* 输出私钥 */

   ticks = (long)time(NULL);
   RAND_add(&ticks, sizeof(ticks), 1); /* srand() */
   BN_rand(k, BN_num_bits(n), 0, 0);   /* 产生随机数k, 位数与n相等 */

   T = EC_POINT_new(group);
   EC_POINT_mul(group, T, k, NULL, NULL, ctx); /* T = k*G */

   EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); /* tx = (k*G).x */
   BN_mod(r, tx, n, ctx); /* r = 签名第1部分 = (k*G).x mod n */

   BN_mod_mul(s, r, d, n, ctx); /* s = r*d mod n */
   BN_bin2bn(plaintext, BN_num_bytes(n), m); /* m = plaintext */

   BN_add(s, s, m); /* s = r*d + m */
   BN_mod(s, s, n, ctx); /* s = r*d + m mod n */
   BN_mod_inverse(tx, k, n, ctx); /* tx = k^-1 mod n */
   BN_mod_mul(s, s, tx, n, ctx); /* s = 签名第2部分 = (r*d+m) / k mod n */

   printf("signature=\n%s;\n%s;\n", BN_bn2hex(r), BN_bn2hex(s));

   puts("Verifying...");
   PT1 = EC_POINT_new(group);
   PT2 = EC_POINT_new(group);
   BN_mod_inverse(tx, s, n, ctx); /* tx = s^-1 mod n */
   BN_mod_mul(tx, m, tx, n, ctx); /* tx = m/s mod n */
   EC_POINT_mul(group, PT1, tx, NULL, NULL, ctx); /* PT1=(m/s)*G */

   BN_mod_inverse(tx, s, n, ctx); /* tx = s^-1 mod n */
   BN_mod_mul(tx, r, tx, n, ctx); /* tx = r/s mod n */
   EC_POINT_mul(group, PT2, NULL, R, tx, ctx); /* PT2=(r/s)*R */

   EC_POINT_add(group, T, PT1, PT2, ctx); /* T = (m/s)*G + (r/s)*R = (mG+rR)/s
                                               = (mG+rdG)/s = (m+rd)G/s 
                                               = (m+rd)G/((m+rd)/k)
                                               = kG
                                           */
   EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); /* tx=kG.x */
   BN_mod(tx, tx, n, ctx); /* tx=kG.x mod n */
   printf("((m/s)*G + (r/s)*R).x mod n=\n%s\n", BN_bn2hex(tx));
   if(BN_ucmp(tx, r)==0)
      puts("The signature is correct.");
   else
      puts("The signature is incorrect.");
   BN_free(p);
   BN_free(a);
   BN_free(b); 
   BN_free(n); 
   BN_free(gx);
   BN_free(gy);
   BN_free(tx);
   BN_free(ty);
   BN_free(m); 
   BN_free(d); 
   BN_free(k); 
   BN_free(r); 
   BN_free(s); 
   EC_POINT_free(G);
   EC_POINT_free(R);
   EC_POINT_free(T);
   EC_POINT_free(PT1);
   EC_POINT_free(PT2);
   BN_CTX_free(ctx);
   EC_GROUP_free(group);
}



void ecc_encrypt_decrypt(void)
{
   unsigned char plaintext[256] = "A QuickBrownFox+ALazyDog"; /* 24 bytes = 192 bits */
   unsigned char ciphertext[512];
   unsigned char bufin[256];
   unsigned char bufout[256];
   unsigned char hex[256];
   long ticks;
   int  ciphertext_len;
   EC_GROUP *group;
   BN_CTX *ctx;
   EC_POINT *G, *T, *R;       /* G是基点, T是临时点, R是公钥点 */
   BIGNUM *p, *a, *b, *n, *gx, *gy, *tx, *ty;
   BIGNUM *m, *d, *k, *r, *s; /* m是明文, d是私钥, k是随机数, r及s是密文 */

   p = BN_new();
   a = BN_new();
   b = BN_new();  /* a,b,p决定曲线 */
   n = BN_new();  /* n是基点G的阶 */
   gx = BN_new(); /* 基点G的x坐标 */
   gy = BN_new(); /* 基点G的y坐标 */
   tx = BN_new(); /* 临时点T的x坐标 */
   ty = BN_new(); /* 临时点T的y坐标 */
   m = BN_new();  /* m是明文 */
   d = BN_new();  /* d是私钥 */
   k = BN_new();  /* k是随机数 */
   r = BN_new();  /* r是密文第1部分 */
   s = BN_new();  /* s是密文第2部分 */


   BN_hex2bn(&a, A);
   BN_hex2bn(&b, B);
   BN_hex2bn(&p, P);
   BN_hex2bn(&n, N);
   BN_hex2bn(&gx, GX);
   BN_hex2bn(&gy, GY);
   BN_hex2bn(&d, D);

   group = EC_GROUP_new(EC_GFp_mont_method()); /* 或EC_GFp_simple_method(); mont: BN_mod_mul_montgomery */
   ctx = BN_CTX_new();
   EC_GROUP_set_curve_GFp(group, p, a, b, ctx);

   G = EC_POINT_new(group);
   EC_POINT_set_affine_coordinates_GFp(group, G, gx, gy, ctx);
   EC_GROUP_set_generator(group, G, n, BN_value_one()); /* 基点=G, G的阶=n, 余因子=1 */
   dump_ecc(group);

   R = EC_POINT_new(group);
   EC_POINT_mul(group, R, d, NULL, NULL, ctx); /* 公钥R = d*G; d是私钥 */
   EC_POINT_get_affine_coordinates_GFp(group, R, tx, ty, ctx); /* tx = (d*G).x */
   printf("R.x=%s\nR.y=%s\n", BN_bn2hex(tx), BN_bn2hex(ty)); /* 输出公钥 */
   printf("d=%s\n", BN_bn2hex(d));  /* 输出私钥 */

   ticks = (long)time(NULL);
   RAND_add(&ticks, sizeof(ticks), 1); /* srand() */
   BN_rand(k, BN_num_bits(n), 0, 0);   /* 产生随机数k, 位数与n相等 */

   T = EC_POINT_new(group);
   EC_POINT_mul(group, T, k, NULL, NULL, ctx); /* T = k*G */

   EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); /* tx = (k*G).x */
   BN_copy(r, tx); /* r = 密文第1部分 = (k*G).x; 注意(k*G).x不可以mod n */

   EC_POINT_mul(group, T, NULL, R, k, ctx); /* T = k*R = k*d*G */
   EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); /* tx = (k*R).x */
   // BN_mod(tx, tx, n, ctx); /* tx = (k*R).x mod n */
   BN_bin2bn(plaintext, BN_num_bytes(n), m); /* m = plaintext */
   BN_mod_mul(s, m, tx, n, ctx); /* s = 密文第2部分 = m * (k*R).x mod n */

   printf("ciphertext=\n%s;\n%s;\n", BN_bn2hex(r), BN_bn2hex(s));

   puts("Decrypting...");
   EC_POINT_set_compressed_coordinates_GFp(group, T, r, 0, ctx); /* T=k*G;
                                                                    其中T的x坐标=r,
                                                                    y坐标自动计算 */
   EC_POINT_mul(group, T, NULL, T, d, ctx); /* T = d*k*G */
   EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx); /* tx = (d*k*G).x */
   // BN_mod(tx, tx, n, ctx); /* tx = (d*k*G).x = (k*R).x mod n */

   BN_mod_inverse(tx, tx, n, ctx); /* tx = tx^-1 = (k*R).x ^ -1 */
   BN_clear(m);
   BN_mod_mul(m, s, tx, n, ctx); /* m = s/(d*r).x = m * (k*R).x / (k*R).x = m */
   memset(plaintext, 0, sizeof(plaintext));
   ciphertext_len = BN_bn2bin(m, plaintext);
   memset(hex, 0, sizeof(hex));
   dump_hex(plaintext, ciphertext_len, hex);
   printf("plaintext=%s\n", hex); 
   puts((char *)plaintext);

   BN_free(p);
   BN_free(a);
   BN_free(b); 
   BN_free(n); 
   BN_free(gx);
   BN_free(gy);
   BN_free(tx);
   BN_free(ty);
   BN_free(m); 
   BN_free(d); 
   BN_free(k); 
   BN_free(r); 
   BN_free(s); 
   EC_POINT_free(G);
   EC_POINT_free(R);
   EC_POINT_free(T);
   BN_CTX_free(ctx);
   EC_GROUP_free(group);
}

void verify_base_point_order(void)
{
   char hex[256];
   EC_GROUP *group;
   BN_CTX *ctx;
   EC_POINT *G, *T=NULL;
   BIGNUM *p, *a, *b, *n, *gx, *gy, *tx, *ty;
   BIGNUM *m;
   int i;

   p = BN_new();
   a = BN_new();
   b = BN_new();  /* a,b,p决定曲线y^2 = x^3 + ax + b (mod p) */
   n = BN_new();  /* n是基点G的阶 */
   gx = BN_new(); /* 基点G的x坐标 */
   gy = BN_new(); /* 基点G的y坐标 */
   tx = BN_new(); /* T点的x坐标; T点用来保存两点之和或点的倍加 */
   ty = BN_new(); /* T点的y坐标 */
   m = BN_new();  /* m用来表示点的倍数 */


   BN_hex2bn(&a, "01");
   BN_hex2bn(&b, "06");
   BN_hex2bn(&p, "0B");   /* y^2 = x^3 + x + 6 mod 11 */
   BN_hex2bn(&n, "0D");   /* 阶 */
   BN_hex2bn(&gx, "02");  /* Gx */
   BN_hex2bn(&gy, "04");  /* Gy */

   group = EC_GROUP_new(EC_GFp_mont_method()); 
   /* 或EC_GFp_simple_method(); mont: BN_mod_mul_montgomery */
   ctx = BN_CTX_new();
   EC_GROUP_set_curve_GFp(group, p, a, b, ctx);
   G = EC_POINT_new(group);
   /*
   EC_POINT_set_compressed_coordinates_GFp(group, G, gx, 0, ctx); //Gx=2, Gy=4 mod 11   ; 0=positive
   EC_POINT_set_compressed_coordinates_GFp(group, G, gx, 1, ctx); //Gx=2, Gy=7=-4 mod 11; 1=negative
   */
   EC_POINT_set_affine_coordinates_GFp(group, G, gx, gy, ctx);
   if(!EC_POINT_is_on_curve(group, G, ctx))
   {
      puts("G is not on the curve!");
      goto verify_base_point_order_done;
   }
   EC_GROUP_set_generator(group, G, n, BN_value_one()); 
   /* 参数3= co-factor(余因子) = 曲线点数/基点G的阶 = BN_value_one() = 1;
      cofactor: A domain parameter in Elliptic curve cryptography, defined 
      as the ratio between the order of a group and that of the subgroup.
    */
   dump_ecc(group);

   T = EC_POINT_new(group);
   EC_POINT_set_to_infinity(group, T);


   for(i=1; i<=13; i++)
   {
      EC_POINT_add(group, T, T, G, ctx); //T=T+G
      if(EC_POINT_is_at_infinity(group, T))
      {
         sprintf(hex, "No.%02d=infinity", i);
      }
      else
      {
         EC_POINT_get_affine_coordinates_GFp(
            group, T, tx, ty, ctx);
         sprintf(hex, "No.%02d=(%s, %s)", i, 
            BN_bn2hex(tx), BN_bn2hex(ty));
      }
      puts(hex);
   }


   for(i=1; i<=13; i++)
   {
      BN_set_word(m, i);
      /* 
      int EC_POINT_mul(const EC_GROUP *, EC_POINT *r, const BIGNUM *m, 
                       const EC_POINT *P, const BIGNUM *n, BN_CTX *ctx);
                       r = G*m + P*n; // G is the base point 
                                      // if (m==NULL) G*m will not be executed
                                      // if (P==NULL) P*n will not be executed
       */
      EC_POINT_mul(group, T, m, NULL, NULL, ctx); /* T = G*m */
      if(EC_POINT_is_at_infinity(group, T))
      {
         sprintf(hex, "No.%02d=infinity", i);
      }
      else
      {
         EC_POINT_get_affine_coordinates_GFp(group, T, tx, ty, ctx);
         sprintf(hex, "No.%02d=(%s, %s)", i, BN_bn2hex(tx), BN_bn2hex(ty));
      }
      puts(hex);
   }

verify_base_point_order_done:
   EC_GROUP_free(group);
   BN_CTX_free(ctx);
   EC_POINT_free(G);
   if(T != NULL)
      EC_POINT_free(T);
   BN_free(p);
   BN_free(a);
   BN_free(b);
   BN_free(n);
   BN_free(gx);
   BN_free(gy);
   BN_free(tx);
   BN_free(ty);
   BN_free(m);
}

main()
{
   verify_base_point_order(); 
   ecc_encrypt_decrypt();
   ecdsa_sign_verify();
   ecnr_sign_verify();
   return 0;
}