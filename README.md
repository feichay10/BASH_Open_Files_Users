# BASH_Open_Files_Users
BASH script to show a list of users with the count of the number of open files that each user currently has

1. Basic function and list of users with open files

The basic function of this script is that if no option is specified, it will display an ordered list and without duplicates of all users
logged into the system and the count of the number of open files that each user currently has. This list is going to be include the users
they are included in the "who" command output.

![alt text](https://raw.githubusercontent.com/feichay10/BASH_Open_Files_Users/master/Default.png)

2. Find files according to a pattern

Add the option '-f | --filter filter' so that filter can be an expression regular. For example: open_files -f .sh

![alt text](https://raw.githubusercontent.com/feichay10/BASH_Open_Files_Users/master/Pattern.png)

3. Files of Users not connected

If the parameter -o | --off_line is included, the previous list must be included but only for users who are not connected to the system, 
that is, those that do not appear in the result of "who".

![alt text](https://raw.githubusercontent.com/feichay10/BASH_Open_Files_Users/master/Offline.png)

4. Filter by user

Outputs a list of users that are specified with the -u | --user option. For example: open_files -u feichay root Cheuk

![alt text](https://raw.githubusercontent.com/feichay10/BASH_Open_Files_Users/master/U_option.png)

5. Combine the options

Also you can combine all the options available on the script
