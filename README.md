# join-linux-windowsAD
There are two processes 
- Regular / manual process
- Automated

The regular manual process has separate files for both CentOS/RHEL, and Ubuntu. 
The automate process is in a separate file (join2domainAutomate.sh) includes both operating systems (CentOS/RHEL, and Ubuntu) in the script. 
Please read through the file, and provide your domain name in the script. 


Join Linux desktop, server to Windows AD 
This is a working script that can be used on the following distros
- CentOS (7/8)
- Ubuntu (18-22) 
- openSuse - not coded

There's one main script file that's universal, runs on any of the distros (Ubuntu / CentOS) and joins it to the domain. 
There's also two different script files that I created then joined them both into one script. 

I used various sources for this, the one that really worked is 
https://zmatech.com/how-to-join-ubuntu-22-04-to-active-directory/?unapproved=99&moderation-hash=e6e09c725c0d876408cd35c00971dc0d#comment-99

There are two different approaches for both CentOS, and Ubuntu depending on your needs. 
I used the process here to only join the Linux workstation/server to the Windows AD -- that means, all AD authenticated users will be able to login to the Linux machine. 

if you like to create separate security groups in AD so only certain users can login to the Linux machines, please feel free to add your comments as it's a work in progress. 


