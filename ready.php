<?php
$mysqli = new mysqli(getenv('MYSQL_HOST'), getenv('MYSQL_USER'), getenv('MYSQL_PASSWORD'), getenv('MYSQL_DATABASE'));

if($mysqli->connect_errno) {
    printf("Database connect failed: %s\n", $mysqli->connect_error);
    exit;
}

/* check if server is alive */
if(!$mysqli->ping()) {
    printf("Database ping error: %s\n", $mysqli->error);
}

/* close connection */
$mysqli->close();

echo "ready";