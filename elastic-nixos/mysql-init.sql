-- create a JDBC test user
CREATE USER 'jdbctest'@'localhost' IDENTIFIED BY 'jdbcpassword';
GRANT ALL PRIVILIGES ON test.* TO 'jdbctest'@'localhost';
FLUSH PRIVILEGES;
