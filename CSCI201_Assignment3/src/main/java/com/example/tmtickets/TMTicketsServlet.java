package com.example.tmtickets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/tmtickets")
public class TMTicketsServlet extends HttpServlet {

    // quick helper to send back json text
    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.write(json);
        out.flush();
    }

    // Other helper
    private String j(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    // pull user id off the session if logged in
    private Integer getUserIdFromSession(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("userId");
        if (obj instanceof Integer) return (Integer) obj;
        if (obj instanceof String) {
            try {
                return Integer.parseInt((String) obj);
            } catch (NumberFormatException ignored) {}
        }
        return null;
    }

    // just grab user name from session
    private String getUsernameFromSession(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("username");
        return (obj == null) ? null : obj.toString();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"No action\"}");
            return;
        }

        switch (action) {
            case "userInfo":
                handleUserInfo(req, resp);
                break;
            case "favorites":
                handleGetFavorites(req, resp);
                break;
            case "wallet":
                handleGetWallet(req, resp);
                break;
            case "logout":
                handleLogout(req, resp);
                break;
            default:
                writeJson(resp, "{\"success\":false,\"message\":\"Unknown action\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"No action\"}");
            return;
        }

        try {
            switch (action) {
                case "signup":
                    handleSignup(req, resp);
                    break;
                case "login":
                    handleLogin(req, resp);
                    break;
                case "purchase":
                    handlePurchase(req, resp);
                    break;
                case "toggleFavorite":
                    handleToggleFavorite(req, resp);
                    break;
                case "trade":
                    handleTrade(req, resp);
                    break;
                default:
                    writeJson(resp, "{\"success\":false,\"message\":\"Unknown action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Server error\"}");
        }
    }

    // ----------  info / auth  ----------

    private void handleUserInfo(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserIdFromSession(req);
        String username = getUsernameFromSession(req);
        if (userId == null || username == null) {
            writeJson(resp, "{\"loggedIn\":false}");
        } else {
            writeJson(resp, "{\"loggedIn\":true,\"username\":\"" + j(username) + "\"}");
        }
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        writeJson(resp, "{\"success\":true}");
    }

    // sign up a new user and log them in
    private void handleSignup(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (email == null || email.isBlank() ||
            username == null || username.isBlank() ||
            password == null || password.isBlank()) {
            writeJson(resp, "{\"success\":false,\"message\":\"All fields required\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // email/username collision
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users WHERE email=? OR username=?")) {
                ps.setString(1, email);
                ps.setString(2, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        writeJson(resp, "{\"success\":false,\"message\":\"Email or username already taken\"}");
                        return;
                    }
                }
            }

            // inserts a user
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO users(email, username, password, cash_balance) VALUES(?,?,?,3000.00)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, email);
                ps.setString(2, username);
                ps.setString(3, password);
                ps.executeUpdate();
                int userId = -1;
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) userId = rs.getInt(1);
                }

                HttpSession session = req.getSession(true);
                session.setAttribute("userId", userId);
                session.setAttribute("username", username);

                writeJson(resp, "{\"success\":true,\"username\":\"" + j(username) + "\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Database error\"}");
        }
    }

    // simple username+password login (plain text)
    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.isBlank() ||
            password == null || password.isBlank()) {
            writeJson(resp, "{\"success\":false,\"message\":\"All fields required\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT id, password FROM users WHERE username=?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Invalid credentials\"}");
                    return;
                }
                int userId = rs.getInt("id");
                String storedPw = rs.getString("password");
                if (!password.equals(storedPw)) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Invalid credentials\"}");
                    return;
                }

                HttpSession session = req.getSession(true);
                session.setAttribute("userId", userId);
                session.setAttribute("username", username);

                writeJson(resp, "{\"success\":true,\"username\":\"" + j(username) + "\"}");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Database error\"}");
        }
    }

    // ---------- favorites ----------

    // add/remove favorite depending on if it already exists
    private void handleToggleFavorite(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserIdFromSession(req);
        if (userId == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }

        String eventId = req.getParameter("eventId");
        String name = req.getParameter("name");
        String localDate = req.getParameter("localDate");
        String venue = req.getParameter("venue");
        String minStr = req.getParameter("minPrice");
        String maxStr = req.getParameter("maxPrice");

        if (eventId == null || eventId.isBlank()) {
            writeJson(resp, "{\"success\":false,\"message\":\"Missing eventId\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT user_id FROM favorites WHERE user_id=? AND event_id=?")) {
                ps.setInt(1, userId);
                ps.setString(2, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
         
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM favorites WHERE user_id=? AND event_id=?")) {
                    ps.setInt(1, userId);
                    ps.setString(2, eventId);
                    ps.executeUpdate();
                }
                writeJson(resp, "{\"success\":true,\"removed\":true}");
            } else {
                // insert favorite
                BigDecimal minPrice = null;
                BigDecimal maxPrice = null;
                if (minStr != null && !minStr.isBlank() && !"N/A".equalsIgnoreCase(minStr)) {
                    minPrice = new BigDecimal(minStr);
                }
                if (maxStr != null && !maxStr.isBlank() && !"N/A".equalsIgnoreCase(maxStr)) {
                    maxPrice = new BigDecimal(maxStr);
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO favorites (user_id, event_id, event_name, local_date, venue, min_price, max_price) " +
                                "VALUES (?,?,?,?,?,?,?)")) {
                    ps.setInt(1, userId);
                    ps.setString(2, eventId);
                    ps.setString(3, name);
                    ps.setString(4, localDate);
                    ps.setString(5, venue);
                    if (minPrice == null) ps.setNull(6, Types.DECIMAL);
                    else ps.setBigDecimal(6, minPrice);
                    if (maxPrice == null) ps.setNull(7, Types.DECIMAL);
                    else ps.setBigDecimal(7, maxPrice);
                    ps.executeUpdate();
                }
                writeJson(resp, "{\"success\":true,\"removed\":false}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Database error\"}");
        }
    }

    // return favorites list as a json
    private void handleGetFavorites(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserIdFromSession(req);
        if (userId == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT event_id, event_name, local_date, venue, min_price, max_price " +
                             "FROM favorites WHERE user_id=?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                List<String> items = new ArrayList<>();
                while (rs.next()) {
                    String eventId = rs.getString("event_id");
                    String name = rs.getString("event_name");
                    String localDate = rs.getString("local_date");
                    String venue = rs.getString("venue");
                    BigDecimal min = rs.getBigDecimal("min_price");
                    BigDecimal max = rs.getBigDecimal("max_price");
                    String minStr = (min == null) ? "N/A" : min.toPlainString();
                    String maxStr = (max == null) ? "N/A" : max.toPlainString();

                    String item = "{"
                            + "\"eventId\":\"" + j(eventId) + "\","
                            + "\"name\":\"" + j(name) + "\","
                            + "\"localDate\":\"" + j(localDate) + "\","
                            + "\"venue\":\"" + j(venue) + "\","
                            + "\"minPrice\":\"" + j(minStr) + "\","
                            + "\"maxPrice\":\"" + j(maxStr) + "\""
                            + "}";
                    items.add(item);
                }
                if (items.isEmpty()) {
                    writeJson(resp, "{\"success\":false,\"message\":\"No favorites\"}");
                } else {
                    String json = "{\"success\":true,\"favorites\":[" + String.join(",", items) + "]}";
                    writeJson(resp, json);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Database error\"}");
        }
    }

    // ---------- wallet + purchasing from details ---------------------------------------------------------------------

    // BUY from details box
    private void handlePurchase(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserIdFromSession(req);
        if (userId == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }

        String eventId = req.getParameter("eventId");
        String name = req.getParameter("name");
        String venue = req.getParameter("venue");
        String minStr = req.getParameter("minPrice");
        String maxStr = req.getParameter("maxPrice");
        String qtyStr = req.getParameter("quantity");

        if (eventId == null || eventId.isBlank() ||
            name == null || name.isBlank() ||
            venue == null || venue.isBlank() ||
            minStr == null || maxStr == null ||
            qtyStr == null || qtyStr.isBlank()) {
            writeJson(resp, "{\"success\":false,\"message\":\"Missing fields\"}");
            return;
        }

        int qty;
        BigDecimal minPrice;
        BigDecimal maxPrice;
        try {
            qty = Integer.parseInt(qtyStr);
            if (qty <= 0) throw new NumberFormatException();
            minPrice = new BigDecimal(minStr);
            maxPrice = new BigDecimal(maxStr);
        } catch (NumberFormatException e) {
            writeJson(resp, "{\"success\":false,\"message\":\"Invalid quantity or price\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {        //thrown here #1
            conn.setAutoCommit(false);

            // lock user row
            BigDecimal cash;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT cash_balance FROM users WHERE id=? FOR UPDATE")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        writeJson(resp, "{\"success\":false,\"message\":\"User not found\"}");
                        return;
                    }
                    cash = rs.getBigDecimal("cash_balance");
                }
            }

            BigDecimal cost = minPrice.multiply(BigDecimal.valueOf(qty));
            if (cash.compareTo(cost) < 0) {
                conn.rollback();
                writeJson(resp, "{\"success\":false,\"message\":\"Insufficient cash\"}");
                return;
            }

            // wallet row (if it exists) possible modify later
            BigDecimal existingQty = BigDecimal.ZERO;
            BigDecimal existingTotalCost = BigDecimal.ZERO;
            boolean hasRow = false;

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT quantity, total_cost FROM wallet WHERE user_id=? AND event_id=? FOR UPDATE")) {
                ps.setInt(1, userId);
                ps.setString(2, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hasRow = true;
                        existingQty = BigDecimal.valueOf(rs.getInt("quantity"));
                        existingTotalCost = rs.getBigDecimal("total_cost");
                    }
                }
            }

            BigDecimal newQty = existingQty.add(BigDecimal.valueOf(qty));
            BigDecimal newTotalCost = existingTotalCost.add(cost);

            if (hasRow) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE wallet SET quantity=?, total_cost=?, venue=?, min_price=?, max_price=? " +
                                "WHERE user_id=? AND event_id=?")) {
                    ps.setInt(1, newQty.intValue());
                    ps.setBigDecimal(2, newTotalCost);
                    ps.setString(3, venue);
                    ps.setBigDecimal(4, minPrice);
                    ps.setBigDecimal(5, maxPrice);
                    ps.setInt(6, userId);
                    ps.setString(7, eventId);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO wallet (user_id, event_id, event_name, venue, min_price, max_price, quantity, total_cost) " +
                                "VALUES (?,?,?,?,?,?,?,?)")) {
                    ps.setInt(1, userId);
                    ps.setString(2, eventId);
                    ps.setString(3, name);
                    ps.setString(4, venue);
                    ps.setBigDecimal(5, minPrice);
                    ps.setBigDecimal(6, maxPrice);
                    ps.setInt(7, qty);
                    ps.setBigDecimal(8, cost);
                    ps.executeUpdate();
                }
            }

            // update cash     double back to REVIEW logic
            BigDecimal newCash = cash.subtract(cost);
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE users SET cash_balance=? WHERE id=?")) {
                ps.setBigDecimal(1, newCash);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            conn.commit();
            writeJson(resp, "{\"success\":true,\"message\":\"SUCCESS: Executed purchase of " + qty + " tickets.\"}");

        } catch (SQLException e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Database error\"}");
        }
    }

    // build wallet summary (cash + positions)
    private void handleGetWallet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserIdFromSession(req);
        if (userId == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            BigDecimal cash = BigDecimal.ZERO;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT cash_balance FROM users WHERE id=?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        cash = rs.getBigDecimal("cash_balance");
                    }
                }
            }

            List<String> positions = new ArrayList<>();
            BigDecimal totalPositionValue = BigDecimal.ZERO;

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT event_id, event_name, venue, min_price, max_price, quantity, total_cost " +
                            "FROM wallet WHERE user_id=?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String eventId = rs.getString("event_id");
                        String name = rs.getString("event_name");
                        String venue = rs.getString("venue");
                        BigDecimal minPrice = rs.getBigDecimal("min_price");
                        BigDecimal maxPrice = rs.getBigDecimal("max_price");
                        int qty = rs.getInt("quantity");
                        BigDecimal totalCost = rs.getBigDecimal("total_cost");

                        if (minPrice == null) minPrice = BigDecimal.ZERO;
                        if (maxPrice == null) maxPrice = BigDecimal.ZERO;

                        BigDecimal avgCost = (qty > 0)
                                ? totalCost.divide(BigDecimal.valueOf(qty), 2, BigDecimal.ROUND_HALF_UP)
                                : BigDecimal.ZERO;
                        BigDecimal change = maxPrice.subtract(minPrice);
                        BigDecimal marketValue = maxPrice.multiply(BigDecimal.valueOf(qty));
                        totalPositionValue = totalPositionValue.add(marketValue);

                        String posJson = "{"
                                + "\"eventId\":\"" + j(eventId) + "\","
                                + "\"name\":\"" + j(name) + "\","
                                + "\"venue\":\"" + j(venue) + "\","
                                + "\"minPrice\":" + minPrice.toPlainString() + ","
                                + "\"maxPrice\":" + maxPrice.toPlainString() + ","
                                + "\"quantity\":" + qty + ","
                                + "\"totalCost\":" + totalCost.toPlainString() + ","
                                + "\"avgCost\":" + avgCost.toPlainString() + ","
                                + "\"change\":" + change.toPlainString() + ","
                                + "\"marketValue\":" + marketValue.toPlainString()
                                + "}";
                        positions.add(posJson);
                    }
                }
            }

            BigDecimal totalAccountValue = cash.add(totalPositionValue);
            String json = "{"
                    + "\"success\":true,"
                    + "\"cashBalance\":" + cash.toPlainString() + ","
                    + "\"totalAccountValue\":" + totalAccountValue.toPlainString() + ","
                    + "\"positions\":[" + String.join(",", positions) + "]"
                    + "}";
            writeJson(resp, json);

        } catch (SQLException e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Database error\"}");
        }
    }

    // BUY/SELL from wallet page
    private void handleTrade(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserIdFromSession(req);
        if (userId == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }

        String side = req.getParameter("side"); // BUY or SELL
        String eventId = req.getParameter("eventId");
        String name = req.getParameter("name");
        String venue = req.getParameter("venue");
        String minStr = req.getParameter("minPrice");
        String maxStr = req.getParameter("maxPrice");
        String qtyStr = req.getParameter("quantity");

        if (side == null || eventId == null || qtyStr == null ||
            side.isBlank() || eventId.isBlank() || qtyStr.isBlank()) {
            writeJson(resp, "{\"success\":false,\"message\":\"Missing fields\"}");
            return;
        }

        int qty;
        BigDecimal minPrice;
        BigDecimal maxPrice;
        try {
            qty = Integer.parseInt(qtyStr);
            if (qty <= 0) throw new Exception();
            minPrice = new BigDecimal(minStr);
            maxPrice = new BigDecimal(maxStr);
        } catch (Exception e) {
            writeJson(resp, "{\"success\":false,\"message\":\"Invalid quantity or price\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            // lock user row
            BigDecimal cash;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT cash_balance FROM users WHERE id=? FOR UPDATE")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        writeJson(resp, "{\"success\":false,\"message\":\"User not found\"}");
                        return;
                    }
                    cash = rs.getBigDecimal("cash_balance");
                }
            }

            // check wallet for this event
            int existingQty = 0;
            BigDecimal existingTotalCost = BigDecimal.ZERO;
            boolean hasRow = false;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT quantity, total_cost FROM wallet WHERE user_id=? AND event_id=? FOR UPDATE")) {
                ps.setInt(1, userId);
                ps.setString(2, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hasRow = true;
                        existingQty = rs.getInt("quantity");
                        existingTotalCost = rs.getBigDecimal("total_cost");
                    }
                }
            }

            if ("BUY".equalsIgnoreCase(side)) {
                BigDecimal cost = minPrice.multiply(BigDecimal.valueOf(qty));
                if (cash.compareTo(cost) < 0) {
                    conn.rollback();
                    writeJson(resp, "{\"success\":false,\"message\":\"Insufficient cash\"}");
                    return;
                }

                int newQty = existingQty + qty;
                BigDecimal newTotalCost = existingTotalCost.add(cost);

                if (hasRow) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE wallet SET quantity=?, total_cost=?, venue=?, min_price=?, max_price=? " +
                                    "WHERE user_id=? AND event_id=?")) {
                        ps.setInt(1, newQty);
                        ps.setBigDecimal(2, newTotalCost);
                        ps.setString(3, venue);
                        ps.setBigDecimal(4, minPrice);
                        ps.setBigDecimal(5, maxPrice);
                        ps.setInt(6, userId);
                        ps.setString(7, eventId);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO wallet (user_id, event_id, event_name, venue, min_price, max_price, quantity, total_cost) " +
                                    "VALUES (?,?,?,?,?,?,?,?)")) {
                        ps.setInt(1, userId);
                        ps.setString(2, eventId);
                        ps.setString(3, name);
                        ps.setString(4, venue);
                        ps.setBigDecimal(5, minPrice);
                        ps.setBigDecimal(6, maxPrice);
                        ps.setInt(7, qty);
                        ps.setBigDecimal(8, cost);
                        ps.executeUpdate();
                    }
                }

                BigDecimal newCash = cash.subtract(cost);
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET cash_balance=? WHERE id=?")) {
                    ps.setBigDecimal(1, newCash);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }

                conn.commit();
                writeJson(resp, "{\"success\":true,\"message\":\"SUCCESS: Executed BUY\"}");

            } else if ("SELL".equalsIgnoreCase(side)) {
                if (!hasRow || existingQty < qty) {
                    conn.rollback();
                    writeJson(resp, "{\"success\":false,\"message\":\"Not enough tickets to sell\"}");
                    return;
                }

                BigDecimal proceeds = maxPrice.multiply(BigDecimal.valueOf(qty));
                int newQty = existingQty - qty;

                BigDecimal avgCost = (existingQty > 0)
                        ? existingTotalCost.divide(BigDecimal.valueOf(existingQty), 2, BigDecimal.ROUND_HALF_UP)
                        : BigDecimal.ZERO;
                BigDecimal newTotalCost = existingTotalCost.subtract(avgCost.multiply(BigDecimal.valueOf(qty)));
                if (newQty == 0) {
                    newTotalCost = BigDecimal.ZERO;
                }

                if (newQty == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM wallet WHERE user_id=? AND event_id=?")) {
                        ps.setInt(1, userId);
                        ps.setString(2, eventId);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE wallet SET quantity=?, total_cost=? WHERE user_id=? AND event_id=?")) {
                        ps.setInt(1, newQty);
                        ps.setBigDecimal(2, newTotalCost);
                        ps.setInt(3, userId);
                        ps.setString(4, eventId);
                        ps.executeUpdate();
                    }
                }

                BigDecimal newCash = cash.add(proceeds);
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET cash_balance=? WHERE id=?")) {
                    ps.setBigDecimal(1, newCash);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }

                conn.commit();
                writeJson(resp, "{\"success\":true,\"message\":\"SUCCESS: Executed SELL\"}");
            } else {
                conn.rollback();
                writeJson(resp, "{\"success\":false,\"message\":\"Unknown side\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            writeJson(resp, "{\"success\":false,\"message\":\"Database error\"}");
        }
    }
}


