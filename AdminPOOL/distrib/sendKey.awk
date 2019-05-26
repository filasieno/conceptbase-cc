{ if($1=="Date:") n=0; else n++; }
{ if (n==7) { email=$0; }} 	# Email
{ if (n==3) { name=$0; }} 		# Name
{ if (n==2) { uni=$0; }} 		# Universitaet
END { printf "setenv email '%s'\n",email; printf "setenv name '%s'\n",name; printf "setenv uni '%s'\n",uni; }
