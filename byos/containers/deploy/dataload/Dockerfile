FROM mcr.microsoft.com/mssql-tools:v1

COPY data_load data_load
COPY sql_data_init.sh .
COPY MYDrivingDB.sql .

USER root 
RUN ["chmod", "+x", "./sql_data_init.sh"]

ENTRYPOINT [ "/bin/bash","-c", "./sql_data_init.sh -s $SQLFQDN -u $SQLUSER -p $SQLPASS -d $SQLDB"]
