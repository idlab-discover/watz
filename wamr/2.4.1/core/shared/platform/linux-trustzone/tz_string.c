#include "platform_api_vmcore.h"
#include <stddef.h>

size_t
strcspn(const char *s1, const char *s2)
{
    EMSG("strcspn is not supported.");
    return -1;
}

char *
strerror(int n)
{
    EMSG("strerror is not supported.");
    return NULL;
}

size_t
strspn(const char *s, const char *accept)
{
    EMSG("strspn is not supported.");
    return -1;
}

//NOTE(Friedrich) Eigen functie
char *
strtok(char *str, const char *delim)
{
    EMSG("strtok is not supported.");
    return NULL;
}

//NOTE(Friedrich) Eigen functie
int
strncasecmp(const char *s1, const char *s2, size_t n)
{
    EMSG("strncasecmp is not supported.");
    return -1;
}
