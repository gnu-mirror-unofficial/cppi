#error 0
#if 0 /* c1 */
# if 0 /* c1 */
#  error 1
# else /* c2 */
#  error 2
# endif /* c3 */
# error 3
#else /* c2 */
# error 4
# if 0 /* c1 */
#  error 5
#  if 0 /* c1 */
#   error 6
#  else /* c2 */
#   error 7
#  endif /* c3 */
#  error 8
# else /* c2 */
#  error 9
# endif /* c3 */
# error a
#endif /* c3 */
#error b
