# Fans Choice 

Hello! Welcome to Fans Choice. Fans Choice is a music ranking platform that allows you to look at top rated albums and singles, and review them. 

## Installation

1) Download the repo by clicking the green download button OR by typing git clone "https://github.com/BryAre/FansChoice.git"      on your terminal

1) Install [node.js](https://nodejs.org/en/)

2) Run the script located at `fanschoice/sql/social.sql`

To run the `fanschoice.sql` script you can try `mysql -u USERNAME -p < /PATH/TO/social.sql` or from the mysql command line try `source ./PATH/TO/fanschoice.sql`.
Can also try mysql -u root -p fanschoice < FansChoice.sql, you should cd to where SQL file is and next to p is name of database. Create database by going to Mariadb and doing Create DATABASENAME; 

3) From the command line `cd path/to/fanschoice; npm install`

4) `node index.js`

5) Go to [http://localhost:3000](http://localhost:3000)



