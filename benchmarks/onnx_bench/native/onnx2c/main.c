#include <stdint.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#include "input.h"

void entry(const float tensor_data[1][3][224][224],
           float tensor_mobilenetv20_output_flatten0_reshape0[1][1000]);

int compare(const void * a, const void * b)
{
  return ( *(float*)a - *(float*)b );
}

int main(void) {
  float output[1][1000];
  // entry(input, output);
  //
  // float max = -1e10;
  // uint8_t res = -1;
  // for (uint16_t i = 0; i < 1000; i++) {
  //   // printf("%d: %.1e - ", i, output_seven[0][i]);
  //   if (output[0][i] > max) {
  //     max = output[0][i];
  //     res = i;
  //   }
  // }
  //
  // printf("The AI overlord thinks that the category was: %d\n", res);

  uint8_t warmup_iters = 20;
  uint8_t timed_iters = 50;
  uint8_t repetition = 10;

  for (uint8_t i = 0; i < warmup_iters; i++) {
    entry(input, output);
  }
 
  float samples[repetition];
  for (uint8_t i = 0; i < repetition; i++) {
    clock_t begin = clock();

    for (uint8_t j = 0; j < timed_iters; j++) {
      entry(input, output);
    }

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    float ns_per_call = time_spent / timed_iters * 1000000000;
    samples[i] = ns_per_call;
  }

  qsort(samples, repetition, sizeof(float), compare);

  float min_val = samples[0];
  float median = samples[repetition / 2];
  float max_val = samples[repetition - 1];
  float pct_spread = (max_val - min_val) / min_val * 100;

  printf("[native] mobilenet: min=%f median=%f max=%f ns/inference (spread %f, n=%d)\n", min_val, median, max_val, pct_spread, repetition);

  return 0;
}

