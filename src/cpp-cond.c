/* C code produced by gperf version 2.7 */
/* Command-line: gperf -a -C -N cpp_cond_lookup -n -p -t -s 6 -k * cpp.gp  */
struct KW {char *name; int code;};

#define TOTAL_KEYWORDS 8
#define MIN_WORD_LENGTH 2
#define MAX_WORD_LENGTH 6
#define MIN_HASH_VALUE 0
#define MAX_HASH_VALUE 75
/* maximum key range = 76, duplicates = 0 */

#ifdef __GNUC__
__inline
#endif
static unsigned int
hash (str, len)
     register const char *str;
     register unsigned int len;
{
  static const unsigned char asso_values[] =
    {
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76,  0, 76, 76,
       5, 25, 15,  0, 76,  0, 76, 76, 15,  0,
       5, 76,  0, 76,  0,  5, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76, 76, 76, 76, 76,
      76, 76, 76, 76, 76, 76
    };
  register int hval = 0;

  switch (len)
    {
      default:
      case 6:
        hval += asso_values[(unsigned char)(unsigned char) str[5]];
      case 5:
        hval += asso_values[(unsigned char)(unsigned char) str[4]];
      case 4:
        hval += asso_values[(unsigned char)(unsigned char) str[3]];
      case 3:
        hval += asso_values[(unsigned char)(unsigned char) str[2]];
      case 2:
        hval += asso_values[(unsigned char)(unsigned char) str[1]];
      case 1:
        hval += asso_values[(unsigned char)(unsigned char) str[0]];
        break;
    }
  return hval;
}

#ifdef __GNUC__
__inline
#endif
const struct KW *
cpp_cond_lookup (str, len)
     register const char *str;
     register unsigned int len;
{
  static const struct KW wordlist[] =
    {
      {"pragma", EIC_PRAGMA},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""},
      {"if", EIC_IF},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {"endif", EIC_ENDIF},
      {""}, {""}, {""}, {""},
      {"elif", EIC_ELIF},
      {""}, {""}, {""}, {""},
      {"ifdef", EIC_IFDEF},
      {""}, {""}, {""}, {""},
      {"ifndef", EIC_IFNDEF},
      {""}, {""}, {""}, {""},
      {"else", EIC_ELSE},
      {""}, {""}, {""}, {""},
      {"define", EIC_DEFINE}
    };

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      register int key = hash (str, len);

      if (key <= MAX_HASH_VALUE && key >= 0)
        {
          register const char *s = wordlist[key].name;

          if (*str == *s && !strcmp (str + 1, s + 1))
            return &wordlist[key];
        }
    }
  return 0;
}
