package com.example.tmtickets;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

        private static final String URL =
        "jdbc:mysql://localhost:3306/ticket_hw3?useSSL=false&serverTimezone=UTC";

    private static final String USER = "root";          
    private static final String PASS = "Nebiyyuyo11$$"; 

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
