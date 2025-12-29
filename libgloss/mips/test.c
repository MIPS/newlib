void outbyte (char);
void print (char *);

int main (void)
{
  outbyte ('&');
  outbyte ('@');
  outbyte ('$');
  outbyte ('%');

  /* whew, we made it */
  
  print ("\r\nDone...");

  return 0;
}
