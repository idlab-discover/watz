/*
 * Copyright (C) 2019 Intel Corporation.  All rights reserved.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

int Host_GenerateKey(uintptr_t *key, uint32_t key_size);
int Host_Encrypt(uintptr_t key, char *src, void *destData, uint32_t destLen,
                 uint32_t *requestedLen, uint32_t requestedLenSize);
int Host_Decrypt(uintptr_t key, void *src, uint32_t srcLen, void *dest,
                 uint32_t destLen, uint32_t *requestedLen,
                 uint32_t requestedLenSize);

int main(int argc, char **argv) {
  if (argc != 2) {
    printf("usage: payload\n");
    return 1;
  }

  char *data = argv[1];

  printf("The payload to encrypt is: %s\n", data);

  uint32_t key_size = 512;
  uintptr_t key;

  Host_GenerateKey(&key, key_size);
  printf("Generated key: %p\n", (void *)key);

  uint32_t *output_size = malloc(sizeof(uint32_t));
  *output_size = 0;
  void *buffer = NULL;

  Host_Encrypt(key, data, buffer, *output_size, output_size,
               sizeof(output_size));

  printf("Requested buffer size: %d\n", *output_size);

  buffer = malloc(*output_size);
  Host_Encrypt(key, data, buffer, *output_size, output_size,
               sizeof(output_size));

  printf("Encrypted buffer: ");
  for (int n = 0; n < *output_size; n++)
    printf("%02x ", ((uint8_t *)buffer)[n]);
  printf("\n");

  void *decrypted_data = NULL;
  uint32_t *decrypted_size = malloc(sizeof(uint32_t));
  *decrypted_size = 0;
  Host_Decrypt(key, buffer, *output_size, decrypted_data, *decrypted_size,
               decrypted_size, sizeof(decrypted_size));

  printf("Requested buffer size: %d\n", *decrypted_size);

  decrypted_data = malloc(sizeof(char) * (*decrypted_size + 1));
  Host_Decrypt(key, buffer, *output_size, decrypted_data,
               sizeof(decrypted_data), decrypted_size, sizeof(decrypted_size));

  char *decrypted_data_string = (char *)decrypted_data;
  decrypted_data_string[*decrypted_size + 1] = '\0';
  printf("Decrypted data: %s\n", decrypted_data_string);

  return 0;
}
