#include "platform_api_vmcore.h"
#include "platform_api_extension.h"
#include "libc_errno.h"

#ifndef FRIEDRICH_APP_FRAMEWORK
static bool is_little_endian()
{
    long i = 0x01020304;
    unsigned char *c = (unsigned char *)&i;
    return (*c == 0x04) ? true : false;
}

static void swap32(uint8 *pData)
{
    uint8 value = *pData;
    *pData = *(pData + 3);
    *(pData + 3) = value;

    value = *(pData + 1);
    *(pData + 1) = *(pData + 2);
    *(pData + 2) = value;
}

//NOTE(Friedrich) Eigen functie
static void swap16(uint8 *pData)
{
    uint8 value = *pData;
    *(pData) = *(pData + 1);
    *(pData + 1) = value;
}

uint32 htonl(uint32 value)
{
    uint32 ret;
    if (is_little_endian()) {
        ret = value;
        swap32((uint8 *)&ret);
        return ret;
    }

    return value;
}

uint32 ntohl(uint32 value)
{
    return htonl(value);
}

uint16 htons(uint16 value)
{
    uint16 ret;
    if (is_little_endian()) {
        ret = value;
        swap16((uint8 *)&ret);
        return ret;
    }

    return value;
}
#endif

int socket(int domain, int type, int protocol)
{
    EMSG("socket is not supported.");
    return -1;
}

int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen)
{
    EMSG("getsockopt is not supported.");
    return -1;
}

ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags)
{
    EMSG("sendmsg is not supported.");
    return -1;
}

ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags)
{
    EMSG("recvmsg is not supported.");
    return -1;
}

int shutdown(int sockfd, int how)
{
    EMSG("shutdown is not supported.");
    return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_listen(bh_socket_t socket, int max_client)
{
   EMSG("os_socket_listen is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_addr_resolve(const char *host, const char *service,
                       uint8_t *hint_is_tcp, uint8_t *hint_is_ipv4,
                       bh_addr_info_t *addr_info, size_t addr_info_size,
                       size_t *max_info_size)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_bind(bh_socket_t socket, const char *host, int *port)
{
    EMSG("os_socket_bind is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_send(bh_socket_t socket, const void *buf, unsigned int len)
{
   EMSG("os_socket_send is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_send_to(bh_socket_t socket, const void *buf, unsigned int len,
                  int flags, const bh_sockaddr_t *dest_addr)
{
   EMSG("os_socket_send_to is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_recv_from(bh_socket_t socket, void *buf, unsigned int len, int flags,
                    bh_sockaddr_t *src_addr)
{
   EMSG("os_socket_recv_from is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_addr_local(bh_socket_t socket, bh_sockaddr_t *sockaddr)
{
   EMSG("os_socket_addr_local is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_addr_remote(bh_socket_t socket, bh_sockaddr_t *sockaddr)
{
   EMSG("os_socket_addr_remote is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_set_send_timeout(bh_socket_t socket, uint64 timeout_us)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_get_send_timeout(bh_socket_t socket, uint64 *timeout_us)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_set_recv_timeout(bh_socket_t socket, uint64 timeout_us)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_get_recv_timeout(bh_socket_t socket, uint64 *timeout_us)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_set_send_buf_size(bh_socket_t socket, size_t bufsiz)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_get_send_buf_size(bh_socket_t socket, size_t *bufsiz)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_set_recv_buf_size(bh_socket_t socket, size_t bufsiz)
{
    errno = ENOSYS;

    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_get_recv_buf_size(bh_socket_t socket, size_t *bufsiz)
{
    errno = ENOSYS;
    return BHT_ERROR;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_inet_network(bool is_ipv4, const char *cp, bh_ip_addr_buffer_t *out)
{
   EMSG("os_socket_inet_network is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie
int
os_socket_create(bh_socket_t *sock, bool is_ipv4, bool is_tcp)
{
   EMSG("os_socket_create is not supported.");
   return -1;
}

//NOTE(Friedrich) Eigen functie en alles eronder ook
int
os_socket_connect(bh_socket_t socket, const char *addr, int port)
{
   EMSG("os_socket_connect is not supported.");
   return -1;
}

int
os_socket_close(bh_socket_t socket)
{
    EMSG("os_socket_close is not supported.");
   return -1;
}

int
os_socket_accept(bh_socket_t server_sock, bh_socket_t *sock, void *addr,
                 unsigned int *addrlen)

{
   EMSG("os_socket_accept is not supported.");
   return -1;
}

__wasi_errno_t
os_socket_shutdown(bh_socket_t socket)
{
    if (shutdown(socket, O_RDWR) != 0) {
        return convert_errno(errno);
    }
    return __WASI_ESUCCESS;
}

int
os_socket_get_ip_multicast_loop(bh_socket_t socket, bool ipv6, bool *is_enabled)
{
   EMSG("os_socket_get_ip_multicast_loop is not supported.");
   return -1;
}

int
os_socket_set_ip_multicast_loop(bh_socket_t socket, bool ipv6, bool is_enabled)
{
   EMSG("os_socket_set_ip_multicast_loop is not supported.");
   return -1;
}

int
os_socket_set_ip_add_membership(bh_socket_t socket,
                                bh_ip_addr_buffer_t *imr_multiaddr,
                                uint32_t imr_interface, bool is_ipv6)
{
   EMSG("os_socket_set_ip_add_membership is not supported.");
   return -1;
}

int
os_socket_set_ip_drop_membership(bh_socket_t socket,
                                 bh_ip_addr_buffer_t *imr_multiaddr,
                                 uint32_t imr_interface, bool is_ipv6)
{
   EMSG("os_socket_set_ip_drop_membership is not supported.");
   return -1;
}

int
os_socket_set_keep_alive(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_keep_alive is not supported.");
   return -1;
}

int
os_socket_get_keep_alive(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_keep_alive is not supported.");
   return -1;
}

int
os_socket_set_reuse_addr(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_reuse_addr is not supported.");
   return -1;
}

int
os_socket_get_reuse_addr(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_reuse_addr is not supported.");
   return -1;
}

int
os_socket_set_reuse_port(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_reuse_port is not supported.");
   return -1;
}

int
os_socket_get_reuse_port(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_reuse_port is not supported.");
   return -1;
}

int
os_socket_get_linger(bh_socket_t socket, bool *is_enabled, int *linger_s)
{
   EMSG("os_socket_get_linger is not supported.");
   return -1;
}

int
os_socket_set_linger(bh_socket_t socket, bool is_enabled, int linger_s)
{
   EMSG("os_socket_set_linger is not supported.");
   return -1;
}

int
os_socket_set_ip_ttl(bh_socket_t socket, uint8_t ttl_s)
{
   EMSG("os_socket_set_ip_ttl is not supported.");
   return -1;
}

int
os_socket_get_ip_ttl(bh_socket_t socket, uint8_t *ttl_s)
{
   EMSG("os_socket_get_ip_ttl is not supported.");
   return -1;
}

int
os_socket_get_ip_multicast_ttl(bh_socket_t socket, uint8_t *ttl_s)
{
   EMSG("os_socket_get_ip_multicast_ttl is not supported.");
   return -1;
}

int
os_socket_set_ip_multicast_ttl(bh_socket_t socket, uint8_t ttl_s)
{
   EMSG("os_socket_set_ip_multicast_ttl is not supported.");
   return -1;
}

int
os_socket_get_ipv6_only(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_ipv6_only is not supported.");
   return -1;
}

int
os_socket_set_ipv6_only(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_ipv6_only is not supported.");
   return -1;
}


int
os_socket_set_tcp_no_delay(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_tcp_no_delay is not supported.");
   return -1;
}

int
os_socket_get_tcp_no_delay(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_tcp_no_delay is not supported.");
   return -1;
}

int
os_socket_set_tcp_quick_ack(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_tcp_quick_ack is not supported.");
   return -1;
}

int
os_socket_get_tcp_quick_ack(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_tcp_quick_ack is not supported.");
   return -1;
}

int
os_socket_set_tcp_keep_idle(bh_socket_t socket, uint32 time_s)
{
   EMSG("os_socket_set_tcp_keep_idle is not supported.");
   return -1;
}

int
os_socket_get_tcp_keep_idle(bh_socket_t socket, uint32 *time_s)
{
   EMSG("os_socket_get_tcp_keep_idle is not supported.");
   return -1;
}

int
os_socket_set_tcp_keep_intvl(bh_socket_t socket, uint32 time_s)
{
   EMSG("os_socket_set_tcp_keep_intvl is not supported.");
   return -1;
}

int
os_socket_get_tcp_keep_intvl(bh_socket_t socket, uint32 *time_s)
{
   EMSG("os_socket_get_tcp_keep_intvl is not supported.");
   return -1;
}

int
os_socket_set_tcp_fastopen_connect(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_tcp_fastopen_connect is not supported.");
   return -1;
}

int
os_socket_get_tcp_fastopen_connect(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_tcp_fastopen_connect is not supported.");
   return -1;
}

int
os_socket_set_broadcast(bh_socket_t socket, bool is_enabled)
{
   EMSG("os_socket_set_broadcast is not supported.");
   return -1;
}

int
os_socket_get_broadcast(bh_socket_t socket, bool *is_enabled)
{
   EMSG("os_socket_get_broadcast is not supported.");
   return -1;
}
