#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
struct record
{
    int a, b, c;
};

void help()
{
    printf("Help : \n"
           "encryptor encrypt/decrypt <file-name> password\n");
}

char * replace(
    char const * const original, 
    char const * const pattern, 
    char const * const replacement
) {
  size_t const replen = strlen(replacement);
  size_t const patlen = strlen(pattern);
  size_t const orilen = strlen(original);

  size_t patcnt = 0;
  const char * oriptr;
  const char * patloc;

  // find how many times the pattern occurs in the original string
  for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen)
  {
    patcnt++;
  }

  {
    // allocate memory for the new string
    size_t const retlen = orilen + patcnt * (replen - patlen);
    char * const returned = (char *) malloc( sizeof(char) * (retlen + 1) );

    if (returned != NULL)
    {
      // copy the original string, 
      // replacing all the instances of the pattern
      char * retptr = returned;
      for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen)
      {
        size_t const skplen = patloc - oriptr;
        // copy the section until the occurence of the pattern
        strncpy(retptr, oriptr, skplen);
        retptr += skplen;
        // copy the replacement 
        strncpy(retptr, replacement, replen);
        retptr += replen;
      }
      // copy the rest of the string.
      strcpy(retptr, oriptr);
    }
    return returned;
  }
}

int encrypt(char* filename, char* passwd)
{
    int passcode = 0;
    for(int i = 0; i<strlen(passwd);i++ ) {
        passcode = passcode + (int)passwd[i];
    }
    struct record read_record;
    FILE * infile;
    FILE * outfile;

    char encrypted_file_name[4096];
    sprintf(encrypted_file_name,"%s.encrypted",filename);

    infile = fopen(filename,"rb");

    if (infile == NULL) {
        printf("Unable to open file '%s'\n",filename);
        return -1;
    }
    outfile = fopen(encrypted_file_name,"wb");
    while(fread(&read_record,sizeof(read_record),1,infile)) {
        read_record.a += passcode * 8;
        read_record.b += passcode * 6;
        read_record.c += passcode * 8;

        fwrite(&read_record,sizeof(read_record),1,outfile);
    }

    fclose(infile);
    fclose(outfile);
    printf("File Encrypted successfully\n");
}

int decrypt(char* filename, char* passwd)
{
    int passcode = 0;
    for(int i = 0; i<strlen(passwd);i++ ) {
        passcode = passcode + (int)passwd[i];
    }
    struct record read_record;
    FILE * infile;
    FILE * outfile;

    char *decrypted_file_name = replace(filename,".encrypted","");
    
    infile = fopen(filename,"rb");
    if (infile == NULL) {
        printf("Unable to open file '%s'\n",filename);
        return -1;
    }

    outfile = fopen(decrypted_file_name,"wb");
    while(fread(&read_record,sizeof(read_record),1,infile)) {
        read_record.a -= passcode * 8;
        read_record.b -= passcode * 6;
        read_record.c -= passcode * 8;

        fwrite(&read_record,sizeof(read_record),1,outfile);
    }

    fclose(infile);
    fclose(outfile);
    printf("File decrypted successfully\n");
}

int
main(int argc, char** argv)
{
    if (argc < 3) {
        help();
        return 0;
    }

    FILE * infile;
    FILE * outfile;

    if (!strcmp(argv[1],"encrypt")) {
        encrypt(argv[2],argv[3]);
    } else {
        decrypt(argv[2],argv[3]);
    }
}