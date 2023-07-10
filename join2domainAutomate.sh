#!/bin/bash

#********************************************************************************
# Logging all the steps

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 
exec 1>>join2domainLOG.txt 2>&1

echo '**************************************************************************' 
echo 'Beginning of Log '
_date=$(date)
echo $_date

echo '*******************************************************'                                
echo                                                                                          
echo 'Instructions'                                                                           
echo 'Join Linux to Windows AD version 1.1'                                                   
echo 'To run the script type sudo bash jointodomain.sh'                                       
echo 'You will need to use your domain admin account to join the domain'                      
echo 'This script is designed to be as generic as possible'                                   
echo 'to run on the following operating systems'                                              
echo 'Ubuntu/CentOS/Redhat'                                                                   
echo 'Script will be updated to accomodate openSuse-leap as well'                             
echo                                                                                          
echo 'Improvements/update section'                                                            
echo '* '                                                                                     
echo                                                                                          
echo '*******************************************************'                                

echo 

#************************************************************
# All the local variable names preceed with an underscore "_"
# Local variables section
#************************************************************
_date_time=$(date)


# ***********************************************************
# All the function names start lower case followed by uppercase
# All functions are defined in this area
# ***********************************************************


# 
# check if a package is already installed 
function checkPackageInstalled()
{
    _software=$1
    echo '--------> checking if package '$_software' is installed'                                             

    if ! command -v $_software &> /dev/null 
    then
        echo 'no'
        return 1
    else 
        echo 'yes'
        return 0
    fi

} # checkPackageInstalled

# ***********************************************************
# Generic function to all Distros to install a package
function installPackage()
{  
    echo ''                                                                                                    
    echo '--------> Installing package'                                                                        

    _package_manager=$1
    _software=$2
    _install_code=1

    echo $_package_manager install $_software                                                                  
    $_package_manager install $_software                                                                       
    _install_code=$?

    # if install successful
    if [[ $_install_code = 0 ]]
    then
        echo $_software ' Installed  '                                                                         
        # echo $_install_code
        return $_install_code

    elif [[ $_install_code = 127 ]]
    then
        echo $_software ' already exists '                                                                     
        # echo $_install_code
        return $_install_code

    else 
        echo $_software ' installation failed '                                                                
        # echo $_install_code
        return $_install_code

    fi # _install_code 

    return $_install_code

} #installPackage

# ***********************************************************
# Find out which distribution we are running on
function getDistributionName
{ 
    # awk offers to specify the field delimiter '=', $1=ID, we print $2
    withQuotes=$(awk -F'=' '$1 == "ID" {print $2}' /etc/os-release)

    # sed replaces a leading " with nothing, and a trailing " with nothing too. 
    # Using -e you can have multiple text processing).
    distributionName=$( sed -e 's/^"//' -e 's/"$//' <<< "$withQuotes" )

    # echo 'You are using ' $distributionName                                                                   
    echo $distributionName
    
} # getDistributionName


# ***********************************************************
# lets verify if domain is discoverable
# if VM is already joined to the domain
function checkIfDomainDiscoverable()
{
    _domain_name=$1
    echo '***************************************************************'                                       >discoverDomainLog.txt
    realm -v discover $_domain_name                                                                            &>>discoverDomainLog.txt
    _discover_code=$(sed -n -e '/Successfully discovered/ s/.*\: *//p'                                            discoverDomainLog.txt)
    
    echo  $_discover_code
    return 0

} # checkIfDomainDiscoverable

# ***********************************************************
# Lets verify if VM is already joined to the domain
function isJoinedToDomain()
{
    _discover_code=$1
    _host_name=$(hostname)

    if [[ $_discover_code = @(xyz.com) ]]
    then
    
    # check if VM is already joined to the domain 
    _vm_status=$(sed -n -e '/configured/ s/.*\: *//p'                                                               discoverDomainLog.txt)
        if [[ $_vm_status = @(kerberos-member) ]]
        then
            echo $_vm_status
            return 0                    
        else
            echo $_vm_status
            return 1                                               
        fi
    fi

    echo $_vm_status
    return 0

} # isJoinedToDomain


#********************************************************************************
# For Ubuntu update the repos only
# For centOS / Redhat use the following commands
# sudo yum makecache

function updateRepos()
{
    echo '--------> Updating Repositories  '                                                                        
    
    _package_manager=$1
    _distro_type=$2

    # echo 'Command sent to this function ' 
    # echo 'package name:' $_package_manager ', distro type: ' $_distro_type

    if [[ $_distro_type = @(ubuntu) ]]
    then

        echo $_package_manager update                                                                                    
        $_package_manager update                                                                                         
        
        # grab the command result
        _update_code=$?

        # if update successful 
        if [[ $_update_code = 0 ]]
        then
            # echo 'Successfully updated your distro '                                                                     
            return $_update_code

        else
            # echo 'Could not update your distro!'                                                                         
            return $_update_code


        fi # update 
    else # if distro = CentOS/RedHat

        echo $_package_manager makecache                                                                                 
        $_package_manager makecache                                                                                      
        
        # grab the command result
        _update_code=$?

        # if update successful 
        if [[ $_update_code = 0 ]]
        then
            # echo 'Successfully updated the repositories  '                                                               
            return $_update_code
            
        else
            # echo 'Could not update repositories !'                                                                       
            return $_update_code
        fi # update 
    fi
                                                             
    echo $_update_code
    return $_update_code

} # updateRepos




#********************************************************************************
# Generic function to distros Ubuntu/CentOS/RedHat/openSuse
# Join VM to domain, accepts _domain_name, _domain_admin_account parameter
function joinToDomain()
{
    echo '--------> Joining to domain  '                                                                                              
    _domain_name=$1
    _domain_admin_account=$2 

    echo 'Attempting to joining to domain' $_domain_name                                                                    
    echo 'realm -v join -U '$_domain_admin_account'@xyz.com' $_domain_name                                                 
    realm -v join -U $_domain_admin_account'@xyz.com' $_domain_name                                                        

    _return_code=$?

    return $_return_code

} # joinToDomain

#********************************************************************************
# Start/Enable SSSD service
startEnableSSSDService()
{
    echo ''                                                                                                                 
    echo 'Restarting SSSD services'                                                                                         
    systemctl restart sssd                                                                                                  
    _restart_code=$?

    if [[ $_restart_code = 0 ]]
    then 
        echo 'Successfully started SSSD services'                                                                           
    else
        echo 'Failed to start SSSD services'                                                                                
    fi

    echo 'Enabling SSSD services'                                                                                           
    systemctl enable sssd                                                                                                   
    _enable_code=$?

    if [[ $_enable_code = 0 ]]
    then 
        echo 'Successfully Enabled SSSD services'                                                                           
    else
        echo 'Failed to enable SSSD services'                                                                               
    fi

} # startEnableSSSDService

#******************************************************************************** 
# This function makes a backup copy of /etc/sssd/sssd.conf, 
# and updates the content in it
writeSSSDConfiguration()
{
    echo '--------> Writing SSSD configuration '                                                                           
    cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.original
    sed -E -i "s/use_fully_qualified_names = True/use_fully_qualified_names = False/" /etc/sssd/sssd.conf
    sed -E -i "s/access_provider = ad/access_provider = simple/" /etc/sssd/sssd.conf

} # writeSSSDConfiguration




#************************************************************
# Control center
# ***********************************************************

# local variables 
_software=realmd
_command=realm
_package_manager=''
_distro_type=''





#************************************************************
# All functions calls happen in this section
# function calls
# important: command is realm, package name is realmd

_distributionName=$(getDistributionName)

# once realm installed / if realm exists check if distro is already joined to the domain
# if already joined to the domain, then exit

# if distribution is ubuntu, then  update and install chrony
if [[ $_distributionName = @(ubuntu) ]]
then

    # call update function

    _package_manager='apt-get -y '
    updateRepos "$_package_manager" $_distributionName
    _update_repos_code=$?

    # if update successful then
    if [[ $_update_repos_code = 0 ]] 
    then 
        # call the install packages function 

        echo 'Successfully updated the apt-get repositories'                                                           

        echo 'Installing missing softwares'                                                                            

        echo '---> realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit'  
        _software='realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit'

        # call install function        
        # installPackage _package_manager=$1 _software=$2
        installPackage "$_package_manager" "$_software"
        $_install_code=$?

        # if installation successful 
        if [[ $_install_code = 0 ]]
        then 
            # check if VM is already joined to the domain
            # call the discover function 
            # checkIfDomainDiscoverable $_domain_name

            _domain_name=ServerName.xyz.com
            _discover_code=$(checkIfDomainDiscoverable $_domain_name)

            _host_name=$(hostname)

            # pass the result of discovery to isjoinedToDomain function
            _vm_status=$(isJoinedToDomain $_discover_code)

            if [[ $_vm_status = @(kerberos-member) ]]
            then
                echo 'VM: '$_host_name ' is already joined to the domain xyz.com, exiting!'                             
                exit 0
            else
                echo 'VM: '$_host_name ' is NOT joined to the domain xyz.com'                                           
                # call join to domain function 
                echo 'Joing VM: '$_host_name ' to the domain xyz.com'                                                   

                echo 'Enter your domain admin account:'                                                                  
                read _domain_admin_account
                joinToDomain $_domain_name $_domain_admin_account
                _join2Domain_code=$?

                if [[ $_join2Domain_code = 0 ]]
                then 
                    echo 'Successfuly joined the domain'                                                                 
                    
                    #start, enable SSSD service
                    startEnableSSSDService

                    # Update /etc/sssd/sssd.conf file     
                    writeSSSDConfiguration

                    #restart SSSD service after update
                    startEnableSSSDService

                    exit 0
                else 
                    echo 'Could not join the domain, please check the mainLog.txt'                                       
                    exit 1

                fi # if joined to domain successfully              

            fi
            
        else 
            echo 'Installation of software ' $_software ' failed!'                                                       
            echo 'Cannot continue '                                                                                      
        fi # if installation of software failed 
    
    else
        echo 'Failed to update the apt-get repositories, cannot continue to install the following software'            
        echo 'realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit'  
        echo 'Please check the mainLog.txt, if continued, VM may become unstable / unusuable '                         


    fi
    
elif [[ $_distributionName = @(centos|rhel) ]]
then 

    _package_manager='yum -y '
    updateRepos "$_package_manager" $_distributionName

    _update_repos_code=$?

    if [[ $_update_repos_code = 0 ]]
    then
        echo 'Successfully updated the yum repositories'                                                            

        _command=realm
        
        # check if realm exists
        # get the _install_code from checkPackageInstalled     
        _install_code=$(checkPackageInstalled $_command)

    else
        echo 'Failed to update the yum repositories, please check the mainLog.txt'                                  

    fi

    # call the install function to install the missing software

    echo 'Installing missing softwares'                                                                            
     _package_manager='yum -y ' 
     _software='sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils'
    
    # call install function        
    # installPackage _package_manager=$1 _software=$2
    installPackage "$_package_manager" "$_software"
    _install_code=$?
    
        # if installation successful 
        if [[ $_install_code = 0 ]]
        then 
            # check if VM is already joined to the domain
            # call the discover function 
            # checkIfDomainDiscoverable $_domain_name

            _domain_name=ServerName.xyz.com
            _discover_code=$(checkIfDomainDiscoverable $_domain_name)

            _host_name=$(hostname)

            # pass the result of discovery to isjoinedToDomain function
            _vm_status=$(isJoinedToDomain $_discover_code)

            if [[ $_vm_status = @(kerberos-member) ]]
            then
                echo 'VM: '$_host_name ' is already joined to the domain xyz.com, exiting!'                             
                exit 0
            else
                echo 'VM: '$_host_name ' is NOT joined to the domain xyz.com'                                           
                # call join to domain function 

                echo 'Joining VM: '$_host_name '  to the domain xyz.com'                                                
                echo 'Enter your domain admin account:'                                                                  
                read _domain_admin_account
                joinToDomain $_domain_name $_domain_admin_account
                _join2Domain_code=$?

                if [[ $_join2Domain_code = 0 ]]
                then 
                    echo 'Successfuly joined the domain'                                                                 
                    
                    #start, enable SSSD service
                    startEnableSSSDService

                    # Update /etc/sssd/sssd.conf file     
                    writeSSSDConfiguration

                    #restart SSSD service after update
                    startEnableSSSDService

                    exit 0
                else 
                    echo 'Could not join the domain, please check the mainLog.txt'                                       
                    exit 1

                fi # if joined to domain successfully
            
            fi
            
        else 
            echo 'Installation of software ' $_software ' failed!'                                                       
            echo 'Cannot join to the domain without the software ' $_software                                            

        fi # if installation of software failed 

    
else # _distributionName is not ubuntu|centos|rhel|opensuse-leap 
    echo 'Your distribution is' $_distributionName                                                                       
    echo 'This script may not work on your distribution '                                                                


fi # _distributionName is ubuntu
