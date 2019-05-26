/* CBase_cvs_update updates the central CBase   */
/* source pool via the command cvs update.      */
/* This file has to be owned by cbase and the   */
/* user id must be set to cbase on execution,   */
/* i.e. permissions for this file have to be    */
/* rwsr-x---                                    */
/* The first argument is the root directory of  */
/* the source pool and the second argument is   */
/* the module which has to be updated, e.g.     */
/*  /home/cbase/CB_NewStruct/src ProductPOOL    */ 
/*						*/
/* October 2002, Christoph Quix                 */
/*						*/


#include<stdio.h>
#include<string.h>

int main(int argc, char* argv[])
{
	char cmd[500];
	int ret;

	if (argc < 3) {
		printf ("\n");
		printf ("Wrong number of arguments\n"); 
		printf ("Usage: CBase_cvs_update <poolroot> <dir>\n");
		exit (1);	
	}

	strcpy(cmd,"cd ");
	strcat(cmd,argv[1]);	
	strcat(cmd," ; ");
	strcat(cmd,"/opt/sfw/bin/cvs update -d -C -l ");
	strcat(cmd,argv[2]);
	printf("Executing as cbase: %s \n",cmd);
	ret = system (cmd);

	exit(ret);
} 

