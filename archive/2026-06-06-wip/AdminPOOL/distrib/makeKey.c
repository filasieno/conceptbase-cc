/*
 * Generation of a key for ConceptBase
 * Keys may be limited
 *  - in time (given by arg1)
 *  - in the number of features available (arg2)
 *  - to a specific user and organization (arg3+4)
 * feature-id is an integer indicating bit-flags, e.g.
 *  "1" means that feature is disable, "7" means feature 1-3 is disabled 
 *  default is 0, i.e. all features are enabled 
 *  see also checkKey or startCBserver.pro
 * */ 

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

	long k1,k2,k3,k4,k5;
	int m,i,len,feature;
	char *name;
	char *org;

	srandom(time(NULL));
	if (argc!=5) {
		printf("Usage: makeKey months feature-id name organization\n");
		return 1;
	}

	m=atoi(argv[1]);
	feature=atoi(argv[2]);
	name=argv[3];
	org=argv[4];

	if (m==0) {
		k1=(long) (6557*(random() % 151)) + 29;
		k2=(long) random() % 1000000;
	}
	else {
		k1=(long) (6557*(random() % 151)) + 37;
		k2=(long) (timetest()+m*31*24*60*60)/1000;
	}
	k3=(long) (k1 % 873) * (k2 % 1189);

	k4=(k1 % 1000)*(987-feature);

	k5=0;
	len=strlen(name);
	for(i=0;i<len;i++) {
	    if((name[i]>='a'&&name[i]<='z')||(name[i]>='A'&&name[i]<='Z'))
	        k5+=name[i];
	}
	len=strlen(org);
	for(i=0;i<len;i++) {
	    if((org[i]>='a'&&org[i]<='z')||(org[i]>='A'&&org[i]<='Z'))
	        k5+=org[i];
	}
	k5=(k1+k2+k3+k4+k5)%987654;

	printf("%06ld %06ld %06ld %06ld %06ld\n",k1,k2,k3,k4,k5);

	return 0;
}

