
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int timetest()
{
       int res;
       time_t l;
       l = time(NULL);
       l = l/20;
       res=(int) (l % 134217728); /* 2^27 (integer limit in Prolog) */
       if(res<0)
          res=res*(-1);
       return res;
}

int main(int argc,char* argv[]) {

	long k1,k2,k3,k4,k5,test,m1,m2,m3,m4,m5,t,rest;
	int i,len;
	char *name;
	char *org;


	if (argc!=8) {
		printf("Usage: checkKey k1 k2 k3 k4 k5 name org\n");
		return 1;
	}

	k1=atoi(argv[1]);
	k2=atoi(argv[2]);
	k3=atoi(argv[3]);
	k4=atoi(argv[4]);
	k5=atoi(argv[5]);
	name=argv[6];
	org=argv[7];

	m5=0;
        len=strlen(name);
        for(i=0;i<len;i++) {
            if((name[i]>='a'&&name[i]<='z')||(name[i]>='A'&&name[i]<='Z'))
                m5+=name[i];
        }
        len=strlen(org);
        for(i=0;i<len;i++) {
            if((org[i]>='a'&&org[i]<='z')||(org[i]>='A'&&org[i]<='Z'))
                m5+=org[i];
        }
	m5=(k1+k2+k3+k4+m5)%987654;
	m1=k1%873;
	m2=k2%1189;
	m3=m1*m2;
	m4=987-(k4/(k1 % 1000));
	test=k1%6557;

        if(m5!=k5) {
	    printf("Regristration key invalid, Name and Organization do not match key\n");
	    return 1;
	}
	if(m3!=k3) {
	    printf("Registration key invalid, inconsistent numbers\n");
	    return 2;
	}
																				   
	if(test==29) {
	    printf("Registration key valid, no expiration date\n");
        }

	if(test==37) {
	   t=timetest();
	   rest=k2*1000-t;
	   if(rest<0) {
	       printf("Registration key expired\n");
	       return 3;
	   }
	   rest=rest/60/60/24;
	   printf("Registration key valid for %ld days\n",rest);
	}

	if(test!=29 && test!=37) {
	    /* K1 is not valid */    
	    printf("Registration key invalid, inconsistent number (1)\n");
	    return 4;
	}

	/* Features */    
	if(m4==0)
	    printf("All features enabled\n");
	if(m4 & 1)
	    printf("Persistency disabled\n");
        if(m4 & 2)
            printf("Multiuser disabled\n");
        if(m4 & 4)
            printf("(FEATURE 3) disabled\n");
        if(m4 & 8)
            printf("(FEATURE 4) disabled\n");

	return 0;
}

