#if(FOO)
#endif

" /* make sure comment in quote is ignored "
#if 1
*/
#else
/* This file has no newline at end.  */
#endif