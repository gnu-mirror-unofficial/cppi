#if !defined (__svr4__) && !defined (__hpux)

extern int sys_nerr;
extern char *sys_errlist[];

char *
strerror(int n)
{
  if (n < 0 || n >= sys_nerr)
    return (0);
  return (sys_errlist[n]);
}
#else
static int hdl_not_used;
#endif
